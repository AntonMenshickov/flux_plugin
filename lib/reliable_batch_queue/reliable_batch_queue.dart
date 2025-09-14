import 'dart:async';

import 'package:flux_plugin/api/api.dart';
import 'package:flux_plugin/model/event_message.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ReliableBatchQueueOptions {
  final int batchSize;
  final int flushIntervalMs;

  ReliableBatchQueueOptions({
    this.batchSize = 1000,
    this.flushIntervalMs = 10000,
  });
}

class ReliableBatchQueue {
  static const String _queueBoxName = 'flux_logs_queue_box';
  static const String _processingBoxName = 'flux_logs_processing_box';

  late final Uuid _uuid;

  late final Box<EventMessage> _queueBox;
  late final Box<EventMessage> _processingBox;

  late final int _batchSize;
  late final int _flushIntervalMs;

  bool _flushing = false;
  int _queueLen = 0;
  int _processingLen = 0;
  Timer? _flushTimer;

  ReliableBatchQueue(ReliableBatchQueueOptions options)
    : _batchSize = options.batchSize,
      _flushIntervalMs = options.flushIntervalMs {
    _uuid = Uuid();
  }

  Future<void> init() async {
    _queueBox = await Hive.openBox(_queueBoxName);
    _processingBox = await Hive.openBox(_processingBoxName);
    await _restoreProcessing();
    _flushTimer ??= Timer.periodic(
      Duration(milliseconds: _flushIntervalMs),
      (_) => _flush(),
    );
  }

  Future<void> _restoreProcessing() async {
    _processingLen = _queueBox.length;
    _queueLen = _processingBox.length;
    if (_processingLen > 0 || _queueLen > 0) {
      await _flush();
    }
  }

  void addEvent(EventMessage event) {
    _queueBox.put(_uuid.v4(), event);
    _queueLen++;
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_queueLen >= _batchSize) {
      await _flush();
    }
  }

  Future<Iterable<EventMessage>> _prepareBatch() async {
    const List<EventMessage> events = [];
    if (_processingLen > 0) {
      events.addAll(_processingBox.values);
    } else {
      final keys = _queueBox.toMap().keys.take(_batchSize);
      for (String key in keys) {
        final EventMessage? event = _queueBox.get(key);
        if (event != null) {
          await _processingBox.add(event);
          await _queueBox.delete(key);
        }
      }
      events.addAll(_processingBox.values);
      _queueLen -= events.length;
      _processingLen += events.length;
    }
    return events;
  }

  Future<void> _flush() async {
    if (_flushing) return;
    _flushing = true;

    final Iterable<EventMessage> batch = await _prepareBatch();

    if (batch.isEmpty) {
      _flushing = false;
      return;
    }
    print('[ReliableBatchQueue] Flushing ${batch.length} messages');

    try {
      Api.uploadEventsBatch(batch);
      await _processingBox.clear();
      _processingLen = 0;
    } catch (err) {
      print(
        '[ReliableBatchQueue] error while flushing messages to database\n$err',
      );
    } finally {
      print('[ReliableBatchQueue] Flushed ${batch.length} messages');
      _flushing = false;
    }
  }
}
