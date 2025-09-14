import 'dart:io';

import 'package:flux_plugin/api/api.dart';
import 'package:flux_plugin/flux_plugin.dart';
import 'package:flux_plugin/reliable_batch_queue/reliable_batch_queue.dart';
import 'package:flux_plugin/utils/printer.dart';

void main() async {
  await FluxLogs.instance.init(
    FluxLogsConfig(
      platform: 'desktop',
      bundleId: 'com.example.app',
      deviceId: 'abcd',
      releaseMode: false,
    ),
    ApiConfig(token: '--token--', url: 'http://127.0.0.1:4000'),
    ReliableBatchQueueOptions(storagePath: Directory.current.path),
    PrinterOptions(
      maxLineLength: 180,
      chunkSize: 4000,
      removeEmptyLines: false,
    ),
  );
  FluxLogs.instance.info(
    'test message with duplicate tags trim\n\nand with empty lines\n\ntest\n\nend',
    tags: ['test', 'debug', 'debug'],
  );
  FluxLogs.instance.info(
    'test message\nwith two lines and two tags',
    tags: ['test', 'debug', 'debug'],
  );
  FluxLogs.instance.warn('test message\nwith a two lines');
  FluxLogs.instance.error(
    'test message with stackTrace and 100 tags\n',
    tags: List.generate(100, (i) => 'tag $i'),
    stackTrace: StackTrace.current,
  );
  FluxLogs.instance.debug('test message\nwith a two lines');

  FluxLogs.instance.debug('\x1B[33mtesting trim \x1B[0mANSI escape sequences');
  FluxLogs.instance.debug(' testing tabulation\n  and spaces');
  // final start = DateTime.timestamp();
  // for (int i = 0; i < 1000; i++) {
  //   FluxLogs.instance.info(
  //     'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.' *
  //         100,
  //     tags: ['test', 'debug', 'debug'],
  //   );
  // }
  // final end = DateTime.timestamp();
  //
  // FluxLogs.instance.debug(
  //   'Operations took ${(end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000}s.',
  // );
}
