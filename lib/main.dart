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
      releaseMode: false,
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
  for (int i = 0; i < 10000; i++) {
    FluxLogs.instance.info(
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
      tags: ['test', 'debug', 'debug'],
    );
  }
}
