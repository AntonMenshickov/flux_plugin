final ansiRegex = RegExp(r'\x1B\[[0-9;]*m');
final lineBreaksRegex = RegExp(r'[\r\n]+');

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  Iterable<String> getLines() =>
      split('\n').map((l) => l.trimRight()).where((l) => l.isNotEmpty);

  String removeAnsiEscape() => replaceAll(ansiRegex, '');

  String removeLineBreaks() => replaceAll(lineBreaksRegex, '');
}
