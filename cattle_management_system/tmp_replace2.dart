import 'dart:io';

String extractMatchingParentheses(String content, int startIndex) {
  int parenCount = 1;
  int currIdx = startIndex;
  String result = "";
  
  while (currIdx < content.length && parenCount > 0) {
    String char = content[currIdx];
    if (char == '(') parenCount++;
    else if (char == ')') parenCount--;
    
    if (parenCount > 0) result += char;
    currIdx++;
  }
  return result;
}

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalReplacements = 0;

  for (var file in files) {
    if (file.path.contains('app_feedback') || file.path.contains('main.dart')) continue;

    String content = await file.readAsString();
    bool changed = false;

    // Use loop to correctly match nested parentheses
    int searchIdx = 0;
    while (true) {
      final match = RegExp(r'ScaffoldMessenger\.of\(\s*([a-zA-Z0-9_]+)\s*\)(?:\.\.clearSnackBars\(\))?\.showSnackBar\(').firstMatch(content.substring(searchIdx));
      if (match == null) break;

      int startIdx = searchIdx + match.start;
      String ctxVar = match.group(1)!;
      
      int contentStart = searchIdx + match.start + match.group(0)!.length;
      String snackbarArgs = extractMatchingParentheses(content, contentStart);
      
      // Calculate where the end of showSnackBar call is
      int endIdx = contentStart + snackbarArgs.length + 1; // +1 for closing parenthesis
      
      if (endIdx < content.length && content[endIdx] == ';') {
        endIdx++;
      }

      // Now extract "content: Text(...)"
      // Find "Text("
      int textIdx = snackbarArgs.indexOf(RegExp(r'Text\s*\('));
      if (textIdx != -1) {
        // Find start of text content
        int textContentStart = snackbarArgs.indexOf('(', textIdx) + 1;
        String textInner = extractMatchingParentheses(snackbarArgs, textContentStart);
        
        String lowerInner = textInner.toLowerCase();
        bool isError = false;
        
        if (snackbarArgs.toLowerCase().contains('colors.red') ||
            lowerInner.contains('error') || lowerInner.contains('fail') || lowerInner.contains('exception') ||
            textInner.startsWith('e.') || textInner.contains(r'$e') || textInner == 'e' || textInner.contains('not implemented') || textInner.contains('mismatch')) {
          isError = true;
        }
        
        if (lowerInner.contains('required') || lowerInner.contains('not found') || lowerInner.contains('please select') || lowerInner.contains('please fill') || lowerInner.contains('please enter')) {
          isError = true;
        }
        
        if (lowerInner.contains('success') || lowerInner.contains('updated') || lowerInner.contains('created') || lowerInner.contains('added') || lowerInner.contains('deleted') || lowerInner.contains('renamed')) {
          if (!lowerInner.contains('fail') && !lowerInner.contains('error')) {
            isError = false;
          }
        }

        String method = isError ? 'showError' : 'showSuccess';
        print('[${file.path}] Repl: $textInner => $method');
        changed = true;
        totalReplacements++;
        
        String replacement = 'AppFeedback.$method($ctxVar, $textInner);';
        content = content.substring(0, startIdx) + replacement + content.substring(endIdx);
        
        searchIdx = startIdx + replacement.length;
      } else {
        searchIdx = endIdx;
      }
    }

    if (changed) {
      if (!content.contains('import \'package:cattle_management_system/core/utils/app_feedback.dart\';') &&
          !content.contains('import \'../../core/utils/app_feedback.dart\';')) {
        
        int importIdx = content.lastIndexOf(RegExp(r"import\s+'[^']+';|import\s+[^;]+;"));
        if (importIdx != -1) {
           int endOfImport = content.indexOf('\n', importIdx);
           content = content.substring(0, endOfImport + 1) + 
                        "import 'package:cattle_management_system/core/utils/app_feedback.dart';\n" + 
                        content.substring(endOfImport + 1);
        } else {
           content = "import 'package:cattle_management_system/core/utils/app_feedback.dart';\n" + content;
        }
      }
      await file.writeAsString(content);
    }
  }
  print("Total replacements: $totalReplacements");
}
