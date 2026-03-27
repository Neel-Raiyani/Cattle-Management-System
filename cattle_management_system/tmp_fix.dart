import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int fixes = 0;
  for (var file in files) {
    if (file.path.contains('app_feedback.dart')) continue;

    String content = await file.readAsString();
    bool changed = false;

    // 1. Fix style: GoogleFonts... syntax error
    if (content.contains('style: GoogleFonts.inter(color: Colors.white)')) {
      content = content.replaceAll(
        RegExp(r',\s*style:\s*GoogleFonts\.inter\(color:\s*Colors\.white\)'), 
        ''
      );
      changed = true;
    }

    // 2. Fix showSuccess -> showError for known error messages
    final exp = RegExp(r'AppFeedback\.showSuccess\([^,]+,\s*(.+?)\);');
    content = content.replaceAllMapped(exp, (match) {
      String inner = match.group(1)!;
      String lower = inner.toLowerCase();
      
      bool isError = false;
      if (lower.contains('please select') || lower.contains('please fill') || lower.contains('please enter') || lower.contains('passwordmismatch') || lower.contains('unable to') || lower.contains('failed') || lower.contains('not implemented')) {
        isError = true;
      }
      
      if (isError) {
        fixes++;
        return match.group(0)!.replaceFirst('showSuccess', 'showError');
      }
      return match.group(0)!;
    });

    if (changed || content != await file.readAsString()) {
      await file.writeAsString(content);
    }
  }
  print('Fixed $fixes incorrect showSuccess calls.');
}
