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
        osName: 'windows 11',
      ),
      releaseMode: false,
      sendLogLevels: {...LogLevel.values},
    ),
    ApiConfig(
      token:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBsaWNhdGlvbklkIjoiNjhlMjIwOTkyMmRmMjk3NjQ5ZjY0MGEwIiwiaWF0IjoxNzU5NjQ5OTQ1LCJleHAiOjQ5MTU0MDk5NDV9.xYWzbpLbNDQbloOo-ciRAzZLp6YbZjge99lyimSKbE0',
      url: 'http://localhost:4000',
    ),
    ReliableBatchQueueOptions(
      storagePath: Directory.current.path,
      flushInterval: Duration(seconds: 30),
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
  flux.warn('test message\nwith a two lines');
  flux.error('test long message with big text ' * 100);
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
