import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalReplacements = 0;

  for (var file in files) {
    if (file.path.contains('app_feedback') || file.path.contains('main.dart')) continue;

    String content = await file.readAsString();
    bool changed = false;

    // A simpler replacement strat:
    // Regex to match the whole scaffolding call
    final exp = RegExp(r'ScaffoldMessenger\.of\(\s*([a-zA-Z0-9_]+)\s*\)(?:\.\.clearSnackBars\(\))?\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\)\s*(?:,\s*backgroundColor:\s*[^)]+)?\s*\)\s*(?:,)?\s*\);?', multiLine: true, dotAll: true);

    String newContent = content.replaceAllMapped(exp, (match) {
      String ctxVar = match.group(1)!;
      String textInner = match.group(2)!.trim();
      
      String lowerInner = textInner.toLowerCase();
      
      bool isError = false;
      String matchStr = match.group(0)!.toLowerCase();
      if (matchStr.contains('colors.red') ||
          lowerInner.contains('error') || lowerInner.contains('fail') || lowerInner.contains('exception') ||
          textInner.startsWith('e.') || textInner.contains(r'$e') || textInner == 'e') {
        isError = true;
      }
      
      if (lowerInner.contains('required') || lowerInner.contains('not found')) {
        isError = true;
      }
      
      if (lowerInner.contains('success') || lowerInner.contains('updated') || lowerInner.contains('created') || lowerInner.contains('added') || lowerInner.contains('deleted')) {
        if (!lowerInner.contains('fail') && !lowerInner.contains('error')) {
          isError = false;
        }
      }
      
      String method = isError ? 'showError' : 'showSuccess';
      print('[${file.path}] Repl: $textInner => $method');
      changed = true;
      totalReplacements++;
      return 'AppFeedback.$method($ctxVar, $textInner);';
    });
    
    // There might be some calls without semicolon or with different formatting.
    final exp2 = RegExp(r'ScaffoldMessenger\.of\(\s*([a-zA-Z0-9_]+)\s*\)\.showSnackBar\(([^;]+)\);?', multiLine: true, dotAll: true);
    
    newContent = newContent.replaceAllMapped(exp2, (match) {
      String inner = match.group(2)!;
      if (inner.contains('SnackBar(content: Text(') && !inner.contains('AppFeedback')) {
         // fallback manually
         final textMatch = RegExp(r'Text\((.*?)\)', dotAll: true).firstMatch(inner);
         if (textMatch != null) {
            String textInner = textMatch.group(1)!.trim();
            String method = textInner.toLowerCase().contains('error') ? 'showError' : 'showSuccess';
            print('[${file.path}] fallback Repl: $textInner => $method');
            changed = true;
            totalReplacements++;
            return 'AppFeedback.$method(${match.group(1)!}, $textInner);';
         }
      }
      return match.group(0)!; // no change
    });


    if (changed) {
      if (!newContent.contains('import \'package:cattle_management_system/core/utils/app_feedback.dart\';') &&
          !newContent.contains('import \'../../core/utils/app_feedback.dart\';')) {
        
        // Find flutter material import or first import
        int importIdx = newContent.lastIndexOf(RegExp(r"import\s+'[^']+';"));
        if (importIdx != -1) {
           int endOfImport = newContent.indexOf('\n', importIdx);
           newContent = newContent.substring(0, endOfImport + 1) + 
                        "import 'package:cattle_management_system/core/utils/app_feedback.dart';\n" + 
                        newContent.substring(endOfImport + 1);
        } else {
           newContent = "import 'package:cattle_management_system/core/utils/app_feedback.dart';\n" + newContent;
        }
      }
      await file.writeAsString(newContent);
    }
  }
  print("Total replacements: $totalReplacements");
}
