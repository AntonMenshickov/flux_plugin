import 'dart:io';

import 'package:flux_plugin/flux_plugin.dart';


void main() async {
  final FluxLogs flux = FluxLogs.instance;
  await flux.init(
    FluxLogsConfig(
      platform: 'android',
      bundleId: 'com.android.app',
      deviceId: 'abcd',
      releaseMode: false,
      sendLogLevels: {...LogLevel.values},
    ),
    ApiConfig(
      token:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBsaWNhdGlvbklkIjoiNjhjNDYzYThjYWNhYmMzNmI5NGFhZjc0IiwiaWF0IjoxNzU3NzAxMDMzLCJleHAiOjQ5MTM0NjEwMzN9.1MVZWfUXLlieQpozW7GGzoQI8kGM9imB7yz2RrKeALQ',
      url: 'http://localhost:4000',
    ),
    ReliableBatchQueueOptions(
      storagePath: Directory.current.path,
      flushInterval: Duration(seconds: 1),
    ),
    PrinterOptions(
      maxLineLength: 180,
      chunkSize: 4000,
      removeEmptyLines: false,
    ),
  );

  flux.setMetaKey('deviceId', 'Unique device id');

  flux.info(
    'test message with duplicate tags trim\n\nand with empty lines\n\ntest\n\nend',
    tags: ['test', 'debug', 'debug'],
  );
  flux.info(
    'test message\nwith two lines and two tags',
    tags: ['test', 'debug', 'debug'],
  );
  flux.warn('test message\nwith a two lines');
  flux.error(
    'test message with stackTrace and 100 tags\n',
    tags: List.generate(100, (i) => 'tag $i'),
    stackTrace: StackTrace.current,
  );
  flux.debug('test message\nwith a two lines');
  flux.debug('\x1B[33mtesting trim \x1B[0mANSI escape sequences');
  flux.debug(' testing tabulation\n  and spaces');
  flux.debug('Testing metadata', meta: {'vehicle': 'A 000 AA 00'});
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
