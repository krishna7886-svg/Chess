import os
import re
import sys

def verify_dart_file(filepath, project_lib_root):
    errors = []
    warnings = []
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.splitlines()

    # 1. Bracket & Brace matching
    stack = []
    bracket_map = {')': '(', '}': '{', ']': '['}
    in_string = False
    string_char = ''
    in_line_comment = False
    in_block_comment = False
    
    i = 0
    line_no = 1
    col_no = 1
    
    while i < len(content):
        ch = content[i]
        
        # Track line numbers
        if ch == '\n':
            line_no += 1
            col_no = 1
            in_line_comment = False
            i += 1
            continue
        else:
            col_no += 1

        # Comments
        if not in_string:
            if not in_block_comment and content[i:i+2] == '//':
                in_line_comment = True
                i += 2
                continue
            if not in_line_comment and not in_block_comment and content[i:i+2] == '/*':
                in_block_comment = True
                i += 2
                continue
            if in_block_comment and content[i:i+2] == '*/':
                in_block_comment = False
                i += 2
                continue

        if in_line_comment or in_block_comment:
            i += 1
            continue

        # Strings
        if not in_string and (ch == "'" or ch == '"'):
            # Check multiline
            if content[i:i+3] == ch * 3:
                in_string = True
                string_char = ch * 3
                i += 3
                continue
            else:
                in_string = True
                string_char = ch
                i += 1
                continue
        elif in_string:
            if string_char in ("'''", '"""'):
                if content[i:i+3] == string_char:
                    in_string = False
                    i += 3
                    continue
            else:
                if ch == '\\':
                    i += 2 # skip escaped character
                    continue
                if ch == string_char:
                    in_string = False
                    i += 1
                    continue
            i += 1
            continue

        # Brackets
        if ch in '({[':
            stack.append((ch, line_no))
        elif ch in ')}]':
            if not stack:
                errors.append(f"Unmatched closing bracket '{ch}' at line {line_no}")
            else:
                top_ch, top_line = stack.pop()
                if top_ch != bracket_map[ch]:
                    errors.append(f"Mismatched bracket '{ch}' at line {line_no}, expected match for '{top_ch}' from line {top_line}")
        i += 1

    if stack:
        for ch, l in stack:
            errors.append(f"Unclosed opening bracket '{ch}' from line {l}")

    # 2. Check local relative imports
    import_pattern = re.compile(r"""import\s+['"]([^'"]+)['"]\s*;""")
    for line_idx, line in enumerate(lines, 1):
        match = import_pattern.search(line)
        if match:
            imp_path = match.group(1)
            if not imp_path.startswith('package:') and not imp_path.startswith('dart:'):
                # Resolve relative path
                dir_path = os.path.dirname(filepath)
                resolved = os.path.normpath(os.path.join(dir_path, imp_path))
                if not os.path.exists(resolved):
                    errors.append(f"Broken relative import at line {line_idx}: '{imp_path}' (resolved: {resolved})")

    # 3. Check MaterialState vs WidgetState (deprecation check)
    for line_idx, line in enumerate(lines, 1):
        if 'MaterialStateProperty' in line:
            warnings.append(f"Line {line_idx}: Uses deprecated MaterialStateProperty (prefer WidgetStateProperty in modern Flutter)")

    return errors, warnings

def main():
    root = os.path.abspath("chess-nexus/mobile/lib")
    test_root = os.path.abspath("chess-nexus/mobile/test")
    
    total_files = 0
    total_errors = 0
    total_warnings = 0
    
    print(f"==================================================")
    print(f" CHESS NEXUS DART CODEBASE STATIC AUDIT")
    print(f" Target: {root}")
    print(f"==================================================")
    
    for base_dir in [root, test_root]:
        if not os.path.exists(base_dir):
            continue
        for dirpath, _, filenames in os.walk(base_dir):
            for fn in filenames:
                if fn.endswith('.dart'):
                    total_files += 1
                    fp = os.path.join(dirpath, fn)
                    rel = os.path.relpath(fp, root)
                    errs, warns = verify_dart_file(fp, root)
                    
                    if errs:
                        total_errors += len(errs)
                        print(f"\n❌ [ERROR] {rel}:")
                        for e in errs:
                            print(f"   - {e}")
                    elif warns:
                        total_warnings += len(warns)
                        print(f"⚠️  [WARN]  {rel}: {len(warns)} warning(s)")
                        for w in warns:
                            print(f"   - {w}")
                    else:
                        print(f"✅ [OK]    {rel}")

    print(f"\n==================================================")
    print(f" SUMMARY: {total_files} Dart files inspected.")
    print(f" Errors: {total_errors} | Warnings: {total_warnings}")
    print(f"==================================================")
    
    if total_errors > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()

