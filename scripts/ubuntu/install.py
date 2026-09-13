#!/usr/bin/env python3
"""Install the reviewed NOSTROMO terminal tools/config into the current Linux user."""
from pathlib import Path
import concurrent.futures, hashlib, io, json, os, platform, re, shutil, subprocess, tarfile, tempfile, urllib.request
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[2]
HOME_DIR = Path.home()
assert platform.system() == 'Linux' and platform.machine() in ('x86_64', 'amd64'), 'Requires Linux x86_64'
releases = json.loads((ROOT / 'scripts/ubuntu/releases.json').read_text())
bin_dir = HOME_DIR / '.local/bin'
backup = HOME_DIR / '.local/state/nostromo/backups' / datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
backup.mkdir(parents=True, mode=0o700)
new_files = []

def replace(target, data, mode=0o644):
    target = Path(target)
    if target.exists() and target.read_bytes() == data:
        return
    if target.exists() or target.is_symlink():
        old = backup / target.relative_to(HOME_DIR)
        old.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(target, old, follow_symlinks=False)
    else:
        new_files.append(str(target.relative_to(HOME_DIR)))
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=target.parent, delete=False) as f:
        f.write(data); tmp = Path(f.name)
    tmp.chmod(mode)
    tmp.replace(target)

def link(target, source):
    target, source = Path(target), Path(source)
    if target.is_symlink() and target.resolve() == source.resolve():
        return
    if target.exists() or target.is_symlink():
        old = backup / target.relative_to(HOME_DIR)
        old.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(target, old, follow_symlinks=False)
        target.unlink()
    else:
        new_files.append(str(target.relative_to(HOME_DIR)))
    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source)

def fetch(item):
    assert item['url'].startswith('https://github.com/')
    request = urllib.request.Request(item['url'], headers={'User-Agent': 'nostromo-setup'})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read()
    assert hashlib.sha256(data).hexdigest() == item['sha256'], 'Checksum mismatch: ' + item['tool']
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as archive:
        matches = [m for m in archive.getmembers() if m.isfile() and Path(m.name).name == item['tool']]
        assert len(matches) == 1, 'Ambiguous binary: ' + item['tool']
        binary = archive.extractfile(matches[0]).read()
    print('Verified ' + item['tool'] + ' ' + item['version'], flush=True)
    return item, binary

# Download and verify all tools before touching the existing shell/config.
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    binaries = list(pool.map(fetch, releases))
for item, data in binaries:
    replace(bin_dir / item['tool'], data, 0o755)
    result = subprocess.run([str(bin_dir/item['tool']), '--version'], capture_output=True, text=True)
    assert result.returncode == 0, item['tool'] + ' cannot run: ' + result.stderr

for rel in ['.config/starship.toml', '.config/fastfetch/config.jsonc', '.config/btop/themes/nostromo.theme', '.config/lazygit/config.yml']:
    link(HOME_DIR/rel, ROOT/rel)
link(HOME_DIR/'.config/btop/btop.conf', ROOT/'scripts/ubuntu/btop.conf')
link(HOME_DIR/'.config/nostromo/init.bash', ROOT/'scripts/ubuntu/init.bash')

# Preserve all existing shell content; replace only our own managed block.
bashrc = HOME_DIR/'.bashrc'
s = bashrc.read_text() if bashrc.exists() else ''
block = '\n# BEGIN NOSTROMO\n[[ -r "$HOME/.config/nostromo/init.bash" ]] && source "$HOME/.config/nostromo/init.bash"\n# END NOSTROMO\n'
s = re.sub(r'\n?# BEGIN NOSTROMO\n.*?# END NOSTROMO\n?', '\n', s, flags=re.S).rstrip() + '\n' + block
replace(bashrc, s.encode())

# Scope terminfo installation to this user. The source is exported from Ghostty.
if shutil.which('tic'):
    subprocess.run(['tic', '-x', '-o', str(HOME_DIR/'.terminfo'), str(ROOT/'scripts/ubuntu/ghostty.terminfo')], check=True)
link(HOME_DIR/'.config/nostromo/releases.json', ROOT/'scripts/ubuntu/releases.json')
(backup/'new-files.json').write_text(json.dumps(new_files, indent=2)+'\n')
subprocess.run(['bash', '-n', str(bashrc)], check=True)
subprocess.run(['bash', '-n', str(HOME_DIR/'.config/nostromo/init.bash')], check=True)
print('Installed NOSTROMO. Rollback copies: ' + str(backup), flush=True)
