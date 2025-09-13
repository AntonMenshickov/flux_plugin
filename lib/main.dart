import 'dart:io';

import 'package:flux_plugin/flux_plugin.dart';

void main() async {
  await FluxLogs.instance.init(
    FluxLogsConfig(
      platform: 'desktop',
      bundleId: 'com.example.app',
      deviceId: 'abcd',
      token: '--token--',
      storagePath: Directory.current.path,
    ),
  );
  FluxLogs.instance.info(
    'test message\nwith two lines',
    tags: ['test', 'debug', 'debug'],
  );
  FluxLogs.instance.warn('test message\nwith a two lines');
  FluxLogs.instance.error(
    'test message\nwith a two lines and stackTrace:\n',
    tags: List.generate(100, (i) => 'tag $i'),
    stackTrace: StackTrace.current,
  );
  FluxLogs.instance.debug('test message\nwith a two lines');

  FluxLogs.instance.info(
    '\x1B[33mtesting trim\n  \x1B[0mANSI escape sequences',
    tags: ['test', 'debug', 'debug'],
  );
}
