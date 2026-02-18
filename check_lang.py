from pathlib import Path
lines = Path('lib/screen/language/local_string.dart').read_text(encoding='utf-8').splitlines()
for idx, line in enumerate(lines,1):
    if ' ADD' in line:
        print(idx, line)
