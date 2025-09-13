import 'dart:math';

import 'package:flux_plugin/extensions/string_extension.dart';
import 'package:flux_plugin/model/log_level.dart';

class Printer {
  static const Map<LogLevel, String> _logLevelAnsiColorCodes = {
    LogLevel.info: '\x1B[34m',
    LogLevel.warn: '\x1B[33m',
    LogLevel.error: '\x1B[31m',
    LogLevel.debug: '\x1B[1;35m',
  };
  static const String _whiteAnsiColorCode = '\x1B[37m';
  static const String _logLevelColorResetAnsiCode = '\x1B[0m';

  static const String _horizontalLine = '\u2500';
  static const String _verticalLine = '\u2502';
  static const String _upLeftCorner = '\u250C';
  static const String _upRightCorner = '\u2510';
  static const String _downLeftCorner = '\u2514';
  static const String _downRightCorner = '\u2518';
  static const String _middleLeftCorner = '\u251C';
  static const String _middleRightCorner = '\u2524';
  static const String _stackTraceLabel = 'Stack trace';


  static void log(
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

  static void _printPrettifiedMessage(
    String message,
    LogLevel level,
    List<String>? tags,
    StackTrace? stackTrace,
  ) {
    if (message.trim().isEmpty && stackTrace == null) {
      return;
    }
    final Iterable<String> lines = message.getLines();
    final Iterable<String>? stackTraceLines = stackTrace?.toString().getLines();
    if (lines.isEmpty && stackTraceLines?.isEmpty == true) {
      return;
    }
    final String colorCode =
        _logLevelAnsiColorCodes[level] ?? _whiteAnsiColorCode;
    final int linesWidth = _getMaxWidthFromLines(lines);
    final int stackTraceWidth = stackTraceLines != null
        ? _getMaxWidthFromLines(stackTraceLines)
        : 0;
    final tagsLabel = tags != null && tags.isNotEmpty
        ? '$_horizontalLine[${tags.take(5).join(", ")}${tags.length > 5 ? ', ...(+${tags.length - 5} tags)' : ''}]$_horizontalLine'
        : '';
    final minWidth = max(
      level.value.length + tagsLabel.length,
      _stackTraceLabel.length,
    );
    final width = max(max(linesWidth, stackTraceWidth), minWidth);
    final String label =
        '$_horizontalLine${level.value.capitalize()}${tagsLabel.isEmpty ? _horizontalLine : ''}$tagsLabel';
    _printColoredMessage(
      _upLeftCorner +
          label +
          _horizontalLine * (width + 2 - label.length) +
          _upRightCorner,
      colorCode,
    );
    for (String line in lines) {
      _printColoredMessage(
        '$_verticalLine ${line.padRight(width)} $_verticalLine',
        colorCode,
      );
    }
    if (stackTraceLines != null) {
      _printColoredMessage(
        _middleLeftCorner +
            _horizontalLine +
            _stackTraceLabel +
            _horizontalLine * (width + 1 - _stackTraceLabel.length) +
            _middleRightCorner,
        colorCode,
      );
      for (String line in stackTraceLines) {
        _printColoredMessage(
          '$_verticalLine ${line.padRight(width)} $_verticalLine',
          colorCode,
        );
      }
    }
    _printColoredMessage(
      _downLeftCorner + _horizontalLine * (width + 2) + _downRightCorner,
      colorCode,
    );
  }

  static void _printColoredMessage(String message, String ansiColorCode) =>
      // ignore: avoid_print
      print('$ansiColorCode$message$_logLevelColorResetAnsiCode');

  static int _getMaxWidthFromLines(Iterable<String> lines) =>
      lines.reduce((a, b) => a.length > b.length ? a : b).length;
}
