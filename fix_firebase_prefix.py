#!/usr/bin/env python3
import sys

with open('lib/screens/verify_code_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace without firebase_auth prefix to with prefix
replacements = [
    ('PhoneAuthProvider.credential', 'firebase_auth.PhoneAuthProvider.credential'),
    ('FirebaseAuth.instance', 'firebase_auth.FirebaseAuth.instance'),
    ('} on FirebaseAuthException catch (e) {', '} on firebase_auth.FirebaseAuthException catch (e) {'),
]

count = 0
for old, new in replacements:
    if old in content:
        content = content.replace(old, new)
        count = content.count(new)
        print(f'✓ Replaced "{old}" with "{new}" (now appears {count} times)')
    else:
        print(f'✗ Not found: "{old}"')

with open('lib/screens/verify_code_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('\n✅ File updated successfully')
sys.exit(0)
