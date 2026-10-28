"""Inspect a locally built prod APK without printing any secret matches."""
import base64
import json
import re
import sys
import zipfile
from pathlib import Path

apk = Path(sys.argv[1])
accounts_file = Path('.env.development-accounts.json')
credentials = json.loads(accounts_file.read_text(encoding='utf-8')) if accounts_file.exists() else {'accounts': []}
secrets = [a.get(k, '').encode() for a in credentials['accounts'] for k in ('email', 'password') if a.get(k)]
properties = Path('android/key.properties').read_text(encoding='utf-8')
secrets += [line.split('=', 1)[1].encode() for line in properties.splitlines()
            if line.startswith(('storePassword=', 'keyPassword='))]
count = 0
with zipfile.ZipFile(apk) as archive:
    for member in archive.infolist():
        assert 'assets/preview/' not in member.filename, 'Preview fixtures bundled in production'
        assert not member.filename.endswith(('.jks', '.keystore', 'key.properties')), 'Private artifact bundled'
        with archive.open(member) as stream:
            tail = b''
            while chunk := stream.read(1024 * 1024):
                data = tail + chunk
                assert not any(secret in data for secret in secrets), 'Credential material in APK (suppressed)'
                assert not re.search(rb'sb_secret_[A-Za-z0-9_-]{20,}|sbp_[A-Za-z0-9]{20,}', data), 'Privileged token in APK'
                assert not re.search(rb'[A-Za-z0-9._+-]+@centerly\.test', data), 'Development identity in production APK'
                for jwt in re.finditer(rb'eyJ[A-Za-z0-9_-]+\.([A-Za-z0-9_-]+)\.[A-Za-z0-9_-]+', data):
                    try:
                        body = json.loads(base64.urlsafe_b64decode(jwt[1] + b'=' * (-len(jwt[1]) % 4)))
                    except (ValueError, UnicodeError):
                        continue
                    assert body.get('role') != 'service_role', 'Privileged JWT in APK'
                tail = data[-4096:]
        count += 1
print(json.dumps({'pass': True, 'apkEntries': count, 'credentialMatches': 0, 'previewAssets': 0}))
