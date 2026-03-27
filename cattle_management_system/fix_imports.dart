import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalFixes = 0;

  for (var file in files) {
    if (file.path.contains('app_feedback.dart')) continue;

    String content = await file.readAsString();
    if (content.contains("'package:cattle_management_system/core/utils/app_feedback.dart'")) {
      // calculate relative path from file to lib/core/utils/app_feedback.dart
      // file.path format: lib\features\...\xyz.dart
      List<String> parts = file.path.replaceAll('\\', '/').split('/');
      // Remove 'lib' and the filename
      int depth = parts.length - 2; 
      String prefix = '';
      if (depth == 0) {
        prefix = './';
      } else {
        for (int i = 0; i < depth; i++) {
          prefix += '../';
        }
      }
      
      String relativeImport = "$prefix" "core/utils/app_feedback.dart";
      content = content.replaceAll(
        "'package:cattle_management_system/core/utils/app_feedback.dart'",
        "'$relativeImport'"
      );
      await file.writeAsString(content);
      totalFixes++;
    }
  }

  print("Total imports fixed: $totalFixes");
}
