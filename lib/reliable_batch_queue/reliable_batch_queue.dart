import 'dart:async';
import 'dart:math';

import 'package:flux_plugin/api/api.dart';
import 'package:flux_plugin/model/event_message.dart';
import 'package:hive/hive.dart';

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

  late final Box<EventMessage> _queueBox;
  late final Box<EventMessage> _processingBox;

  late final int _batchSize;
  late final int _flushIntervalMs;

  int _sequenceKey = 0;
  bool _flushing = false;
  Timer? _flushTimer;

  ReliableBatchQueue(ReliableBatchQueueOptions options)
    : _batchSize = options.batchSize,
      _flushIntervalMs = options.flushIntervalMs;

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
    final Iterable<MapEntry<int, EventMessage>> processingKeys = _processingBox
        .toMap()
        .entries
        .cast();
    for (var entry in processingKeys) {
      if (_queueBox.get(entry.key) == null) {
        await _queueBox.put(entry.key, entry.value);
      }
    }
    await _processingBox.clear();
    if (_queueBox.isNotEmpty) {
      _sequenceKey = _queueBox.keys.cast<int>().reduce(max);
    } else {
      _sequenceKey = 0;
    }
    if (_processingBox.length > 0 || _queueBox.length > 0) {
      await _flush();
    }
  }

  void addEvent(EventMessage event) async {
    await _queueBox.put(++_sequenceKey, event);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_queueBox.length >= _batchSize) {
      await _flush();
    }
  }

  Future<Iterable<EventMessage>> _prepareBatch() async {
    final List<EventMessage> events = [];
    if (_processingBox.length > 0) {
      events.addAll(_processingBox.values);
    } else {
      final List<int> keys =
          (_queueBox.toMap().keys.toList().cast<int>()
                ..sort((a, b) => a.compareTo(b)))
              .take(_batchSize)
              .toList();
      for (int key in keys) {
        final EventMessage? event = _queueBox.get(key);
        if (event != null) {
          await _processingBox.put(key, event);
          await _queueBox.delete(key);
        }
      }
      events.addAll(_processingBox.values);
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
      await Api.uploadEventsBatch(batch);
      await _processingBox.clear();
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
