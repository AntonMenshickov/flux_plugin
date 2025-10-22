import 'dart:io';

import 'package:flux_plugin/flux_plugin.dart';

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
    ApiConfig(token: '', url: 'http://localhost:4000'),
    ReliableBatchQueueOptions(
      storagePath: Directory.current.path,
      flushInterval: Duration(seconds: 30),
      batchSize: 100,
      maxStoredRecords: 10000,
      cacheStrategy: CacheStrategy.keepOld,
    ),
    PrinterOptions(
      maxLineLength: 0,
      removeEmptyLines: false,
      enableAnsiCodes: true,
    ),
  );

  flux.setMetaKey('deviceId', 'Unique device id');
  flux.setMetaKey('vehicle', '0 AAA 00 154');
  // final random = Random(DateTime.timestamp().millisecondsSinceEpoch);
  // int index = 0;
  // while (true) {
  //   final String message = 'Event message ${index++}';
  //   final List<String> tags = ['test'];
  //   switch (random.nextInt(5)) {
  //     case 0:
  //       flux.warn(message, tags: tags);
  //       break;
  //     case 1:
  //       flux.info(message);
  //       break;
  //     case 2:
  //       flux.error(message, tags: tags);
  //       break;
  //     case 3:
  //       flux.debug(message, tags: tags);
  //       break;
  //     case 4:
  //       flux.crash(message, tags: tags);
  //       break;
  //   }
  //   await Future.delayed(Duration(milliseconds: 1000));
  // }
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
