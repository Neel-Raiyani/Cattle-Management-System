import 'dart:io'; void main() { for (var line in File('errors.txt').readAsLinesSync()) { if (line.contains('ERROR')) { print(line.split('|').sublist(4, 8).join(' | ')); } } }
