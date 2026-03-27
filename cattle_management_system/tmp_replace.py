import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    idx = 0
    while idx < len(content):
        # Allow multi-line whitespace around the text
        match = re.search(r'ScaffoldMessenger\.of\(\s*([a-zA-Z0-9_]+)\s*\)(?:\.\.clearSnackBars\(\))?\.showSnackBar\(', content[idx:])
        if not match:
            break
        
        start_idx = idx + match.start()
        context_var = match.group(1)
        
        paren_count = 1
        curr_idx = start_idx + len(match.group(0))
        snack_bar_inner = ""
        while curr_idx < len(content) and paren_count > 0:
            char = content[curr_idx]
            if char == '(':
                paren_count += 1
            elif char == ')':
                paren_count -= 1
            if paren_count > 0:
                snack_bar_inner += char
            curr_idx += 1

        if curr_idx < len(content) and content[curr_idx] == ';':
            curr_idx += 1
        
        # Now parse the text content
        # It's usually SnackBar(content: Text('message'))
        # But we only have inside showSnackBar(...)
        text_match = re.search(r'content:\s*Text\((.*?)\)', snack_bar_inner, re.DOTALL)
        if text_match:
            text_inner = text_match.group(1).strip()
            
            is_error = False
            lower_inner = text_inner.lower()
            if 'colors.red' in snack_bar_inner.lower() or 'error' in lower_inner or 'fail' in lower_inner or 'exception' in lower_inner or text_inner.startswith('e.') or '$e' in text_inner:
                is_error = True

            if 'required' in lower_inner or 'not found' in lower_inner:
                is_error = True
            
            if 'success' in lower_inner or 'updated' in lower_inner or 'created' in lower_inner or 'added' in lower_inner or 'deleted' in lower_inner:
                if 'fail' not in lower_inner and 'error' not in lower_inner:
                    is_error = False
            
            # fallback to error if variable is `e`
            if text_inner == 'e':
                is_error = True

            method = "showError" if is_error else "showSuccess"
            print(f"[{os.path.basename(filepath)}] Found: {text_inner} => {method}")

        idx = curr_idx

def main():
    lib_dir = "d:\\Desktop\\Cattle-Management-System\\cattle_management_system\\lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
