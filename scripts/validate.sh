#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "Validation failed: $*" >&2
  exit 1
}

required_paths=(
  VERSION
  scripts/check-packages.sh
  profiles/common/config/package-lists/common.list.chroot
  profiles/desktop/config/package-lists/desktop.list.chroot
  profiles/server/config/package-lists/server.list.chroot
  profiles/common/config/includes.chroot/usr/lib/os-release
  .github/workflows/validate.yml
  .github/workflows/build-iso.yml
)

for path in "${required_paths[@]}"; do
  [[ -f "$path" ]] || fail "missing ${path}"
done

while IFS= read -r -d '' script; do
  bash -n "$script" || fail "invalid Bash syntax in ${script}"
done < <(find scripts -type f -name '*.sh' -print0)

while IFS= read -r -d '' hook; do
  sh -n "$hook" || fail "invalid POSIX shell syntax in ${hook}"
done < <(find profiles -type f -name '*.hook.chroot' -print0)

for script in scripts/*.sh; do
  [[ -x "$script" ]] || fail "script is not executable: ${script}"
done

while IFS= read -r list; do
  duplicates="$(awk '!/^[[:space:]]*(#|$)/ {print $1}' "$list" | sort | uniq -d)"
  [[ -z "$duplicates" ]] || fail "duplicate packages in ${list}: ${duplicates}"
done < <(find profiles -type f -name '*.list.chroot' | sort)

grep -qx 'ID=sovereign-stack' \
  profiles/common/config/includes.chroot/usr/lib/os-release \
  || fail "os-release must declare ID=sovereign-stack"
grep -qx 'ID_LIKE=debian' \
  profiles/common/config/includes.chroot/usr/lib/os-release \
  || fail "os-release must retain Debian lineage"

grep -q '^task-kde-desktop$' \
  profiles/desktop/config/package-lists/desktop.list.chroot \
  || fail "Desktop profile is missing KDE Plasma"
grep -q '^calamares$' \
  profiles/desktop/config/package-lists/desktop.list.chroot \
  || fail "Desktop profile is missing Calamares"

if grep -Eiq '^(task-.*desktop|kde|plasma|xorg|calamares)' \
  profiles/server/config/package-lists/server.list.chroot; then
  fail "Server profile contains a graphical package"
fi

if grep -RInE 'curl[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash)' \
  --exclude-dir=build --exclude-dir=out .; then
  fail "piped remote shell execution is prohibited"
fi

if grep -RInE 'http://(deb|security)\.debian\.org' \
  --exclude-dir=build --exclude-dir=out .; then
  fail "Debian mirrors must use HTTPS"
fi

python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET

try:
    import yaml
except ImportError as exc:
    raise SystemExit(f"PyYAML is required for validation: {exc}")

for path in sorted(Path('.github/workflows').glob('*.yml')):
    with path.open('r', encoding='utf-8') as handle:
        yaml.safe_load(handle)

for path in sorted(Path('profiles').rglob('*.svg')):
    ET.parse(path)
PY

if grep -rIl $'\r' README.md docs scripts profiles .github builder VERSION; then
  fail "CRLF line endings detected"
fi

echo "Validation passed for Sovereign Stack OS $(tr -d '[:space:]' < VERSION)."
