import 'dart:convert';

final ansiRegex = RegExp(r'\x1B\[[0-9;]*m');
final lineBreaksRegex = RegExp(r'[\r\n]+');
final spaceCharactersRegex = RegExp(r'\s+');

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  Iterable<String> getLines() sync* {
    final lines = LineSplitter.split(this);
    for (var line in lines) {
      line = line.trimRight();
      if (line.isNotEmpty) yield line;
    }
  }

  String removeAnsiEscape() => replaceAll(ansiRegex, '');

  String removeLineBreaks() => replaceAll(lineBreaksRegex, '');

  List<String> splitByWords(int maxLength) {
    if (length <= maxLength) return [this];

    final result = <String>[];
    final words = split(spaceCharactersRegex);
    final sb = StringBuffer();
    for (String word in words) {
      if (sb.isEmpty) {
        sb.write(word);
      } else if (sb.length + 1 + word.length <= maxLength) {
        sb.write(' $word');
      } else {
        result.add(sb.toString());
        sb
          ..clear()
          ..write(word);
      }
    }
    if (sb.isNotEmpty) result.add(sb.toString());
    return result;
  }
}
