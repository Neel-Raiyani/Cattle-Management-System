import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalFixes = 0;
  
  final errorStrings = [
    'Please select an animal name',
    'Please select a dose date',
    'Please select at least one animal',
    'Please select dose type',
    'Please fill required fields',
    'Please enter the vaccine name.',
    'Please enter the disease name.',
    'Please select an animal first.',
    'Failed to change password',
    'Failed to reset password',
    'Unable to export monthly report right now.',
    'AppLocalizations.of(context)!.passwordMismatch'
  ];

  for (var file in files) {
    if (file.path.contains('app_feedback.dart')) continue;

    String content = await file.readAsString();
    bool changed = false;

    for (var errorStr in errorStrings) {
      // Find exact matches of AppFeedback.showSuccess(..., errorStr)
      // Note: errorStr might be a string literal with quotes or a variable without quotes.
      // Easiest is to search for showSuccess in the same line as errorStr.
      
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('AppFeedback.showSuccess') && lines[i].contains(errorStr)) {
          lines[i] = lines[i].replaceFirst('showSuccess', 'showError');
          changed = true;
          totalFixes++;
        }
      }
      if (changed) {
        content = lines.join('\n');
      }
    }

    if (changed) {
      await file.writeAsString(content);
    }
  }

  print('Total strict fixes applied: $totalFixes');
}
