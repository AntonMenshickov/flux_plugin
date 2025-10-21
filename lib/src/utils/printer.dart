import 'dart:math';

import 'package:flux_plugin/src/extensions/string_extension.dart';
import 'package:flux_plugin/src/model/log_level.dart';

class PrinterOptions {
  ///maximum line length
  final int maxLineLength;

  final bool removeEmptyLines;

  ///enable colored log output (some platforms and ide`s not support)
  final bool enableAnsiCodes;

  const PrinterOptions({
    this.maxLineLength = 200,
    this.removeEmptyLines = false,
    this.enableAnsiCodes = true,
  });
}

class Printer {
  static const Map<LogLevel, String> _logLevelAnsiColorCodes = {
    LogLevel.info: '\x1B[34m',
    LogLevel.warn: '\x1B[33m',
    LogLevel.error: '\x1B[31m',
    LogLevel.crash: '\x1B[2;31m',
    LogLevel.debug: '\x1B[1;35m',
  };
  static const String _whiteAnsiColorCode = '\x1B[37m';

  static const String _horizontalLine = '\u2500';
  static const String _verticalLine = '\u2502';
  static const String _upLeftCorner = '\u250C';
  static const String _upRightCorner = '\u2510';
  static const String _downLeftCorner = '\u2514';
  static const String _downRightCorner = '\u2518';
  static const String _middleLeftCorner = '\u251C';
  static const String _middleRightCorner = '\u2524';
  static const String _stackTraceLabel = 'Stack trace';

  final int _maxLineLength;
  final bool _removeEmptyLines;
  final bool _enableAnsiCodes;
  final String _resetAnsiCode;

  Printer(PrinterOptions options)
    : _maxLineLength = options.maxLineLength,
      _removeEmptyLines = options.removeEmptyLines,
      _enableAnsiCodes = options.enableAnsiCodes,
      _resetAnsiCode = options.enableAnsiCodes ? '\x1B[0m' : '';

  void log(
    String message, [
    LogLevel level = LogLevel.info,
    List<String>? tags,
    StackTrace? stackTrace,
  ]) => _printPrettifiedMessage(
    message.removeAnsiEscape(),
    level,
    tags,
    stackTrace,
  );

  void _printPrettifiedMessage(
    String message,
    LogLevel level,
    List<String>? tags,
    StackTrace? stackTrace,
  ) {
    if (message.trim().isEmpty && stackTrace == null) return;

    final List<String> lines = [];
    for (var line in message.getLines(removeEmptyLines: _removeEmptyLines)) {
      if (line.length > _maxLineLength) {
        lines.addAll(line.splitByWords(_maxLineLength));
      } else {
        lines.add(line);
      }
    }

    final Iterable<String> stackTraceLines =
        stackTrace?.toString().getLines(removeEmptyLines: false) ?? [];

    final String colorCode = _enableAnsiCodes
        ? _logLevelAnsiColorCodes[level] ?? _whiteAnsiColorCode
        : '';

    final int linesWidth = lines.isEmpty
        ? 0
        : lines.map((l) => l.length).reduce(max);
    final int stackTraceWidth = stackTraceLines.isEmpty
        ? 0
        : stackTraceLines.map((l) => l.length).reduce(max);

    final String tagsLabel = (tags != null && tags.isNotEmpty)
        ? '$_horizontalLine[${tags.take(5).join(", ")}${tags.length > 5 ? ', ...(+${tags.length - 5} tags)' : ''}]$_horizontalLine'
        : '';

    final int minWidth = max(
      level.value.length + tagsLabel.length,
      _stackTraceLabel.length,
    );
    final int width = max(max(linesWidth, stackTraceWidth), minWidth);

    final String label =
        '$_horizontalLine${level.value.capitalize()}${tagsLabel.isEmpty ? _horizontalLine : ''}$tagsLabel';

    // ignore: avoid_print
    print(
      '$colorCode$_upLeftCorner$label${_horizontalLine * (width + 2 - label.length)}$_upRightCorner$_resetAnsiCode',
    );

    for (final line in lines) {
      // ignore: avoid_print
      print(
        '$colorCode$_verticalLine ${line.padRight(width)} $_verticalLine$_resetAnsiCode',
      );
    }

    if (stackTraceLines.isNotEmpty) {
      // ignore: avoid_print
      print(
        '$colorCode$_middleLeftCorner$_horizontalLine$_stackTraceLabel${_horizontalLine * (width + 1 - _stackTraceLabel.length)}$_middleRightCorner$_resetAnsiCode',
      );

      for (final line in stackTraceLines) {
        // ignore: avoid_print
        print(
          '$colorCode$_verticalLine ${line.padRight(width)} $_verticalLine$_resetAnsiCode',
        );
      }
    }

    // ignore: avoid_print
    print(
      '$colorCode$_downLeftCorner${_horizontalLine * (width + 2)}$_downRightCorner$_resetAnsiCode',
    );
  }
}
