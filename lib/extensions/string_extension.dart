final ansiRegex = RegExp(r'\x1B\[[0-9;]*m');
final lineBreaksRegex = RegExp(r'[\r\n]+');

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  Iterable<String> getLines() =>
      split('\n').map((l) => l.trimRight()).where((l) => l.isNotEmpty);

  String removeAnsiEscape() => replaceAll(ansiRegex, '');

  String removeLineBreaks() => replaceAll(lineBreaksRegex, '');

  List<String> splitByWords(int maxLength) {
    List<String> result = [];
    List<String> words = split(RegExp(r'\s+'));
    String currentLine = '';

    for (var word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ((currentLine.length + 1 + word.length) <= maxLength) {
        currentLine += ' $word';
      } else {
        result.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      result.add(currentLine);
    }

    return result;
  }
}
