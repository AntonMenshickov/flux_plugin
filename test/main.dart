import 'dart:io';
import 'dart:math';

import 'package:flux_plugin/flux_plugin.dart';

final _words = [
  'lorem',
  'ipsum',
  'dolor',
  'sit',
  'amet',
  'consectetur',
  'adipiscing',
  'elit',
  'sed',
  'do',
  'eiusmod',
  'tempor',
  'incididunt',
  'ut',
  'labore',
  'et',
  'dolore',
  'magna',
  'aliqua',
];

String generateLorem(int wordCount) {
  final rnd = Random();
  return List.generate(
    wordCount,
    (_) => _words[rnd.nextInt(_words.length)],
  ).join(' ');
}

Map<String, String> listToMap(List<String> list) {
  final map = <String, String>{};
  for (var i = 0; i < list.length; i += 2) {
    map[list[i]] = list[i + 1];
  }
  return map;
}

void main() async {
  final FluxLogs flux = FluxLogs.instance;
  await flux.init(
    FluxLogsConfig(
      deviceInfo: DeviceInfo(
        platform: 'android',
        bundleId: 'com.example.android',
        deviceId: 'abcd',
        deviceName: 'ANTON PC',
        osName: 'windows 11 windows 11 windows 11',
      ),
      releaseMode: false,
      sendLogLevels: {...LogLevel.values},
      enableSocketConnection: true,
    ),
    ApiConfig(
      token:
          '',
      url: 'http://localhost:4000',
    ),
    ReliableBatchQueueOptions(
      storagePath: Directory.current.path,
      flushInterval: Duration(seconds: 30),
      batchSize: 1000,
      maxStoredRecords: 10000,
      cacheStrategy: CacheStrategy.keepOld,
    ),
    PrinterOptions(
      maxLineLength: 180,
      removeEmptyLines: false,
      enableAnsiCodes: true,
    ),
  );

  flux.setMetaKey('deviceId', 'Unique device id');
  final random = Random(DateTime.timestamp().millisecondsSinceEpoch);
  while (true) {
    final String message = generateLorem(5 + random.nextInt(45));
    final List<String> tags = generateLorem(random.nextInt(5)).split(' ').where((e) => e.isNotEmpty).toList();
    final metaWords = generateLorem(random.nextInt(3) * 2);
    late final Map<String, String>? meta;
    if (metaWords.isNotEmpty) {
      meta = listToMap(metaWords.split(' '));
    } else {
      meta = {};
    }
    switch (random.nextInt(5)) {
      case 0:
        flux.warn(message, tags: tags, meta: meta);
        break;
      case 1:
        flux.info(message, tags: tags, meta: meta);
        break;
      case 2:
        flux.error(
          message,
          tags: tags,
          meta: meta,
          stackTrace: StackTrace.current,
        );
        break;
      case 3:
        flux.debug(message, tags: tags, meta: meta);
        break;
      case 4:
        flux.crash(
          message,
          tags: tags,
          meta: meta,
          stackTrace: StackTrace.current,
        );
        break;
    }
    if (random.nextInt(100) == 0) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }
  // flux.info(
  //   'test message with duplicate tags trim\n\nand with empty lines\n\ntest\n\nend',
  //   tags: ['test', 'debug', 'debug'],
  // );
  // flux.info(
  //   'test message\nwith two lines and two tags',
  //   tags: ['test', 'debug', 'debug'],
  // );
  // flux.warn('test message\nwith a two lines');
  // flux.warn('test message\nwith a two lines');
  // flux.error('test long message with big text ' * 100);
  // flux.error(
  //   'test message with stackTrace and 100 tags\n',
  //   tags: List.generate(100, (i) => 'tag $i'),
  //   stackTrace: StackTrace.current,
  // );
  // flux.debug('test message\nwith a two lines');
  // flux.debug('\x1B[33mtesting trim \x1B[0mANSI escape sequences');
  // flux.debug(' testing tabulation\n  and spaces');
  // flux.debug('Testing metadata', meta: {'vehicle': 'A 000 AA 00'});
  // final start = DateTime.timestamp();
  // for (int i = 0; i < 1000; i++) {
  //   flux.info('$i', tags: ['test', 'debug']);
  // }
  // final end = DateTime.timestamp();
  //
  // flux.debug(
  //   'Operations took ${(end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000}s.',
  // );
}
