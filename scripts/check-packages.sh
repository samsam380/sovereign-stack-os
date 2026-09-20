#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v apt-cache >/dev/null 2>&1; then
  echo "apt-cache is required to check Debian package availability." >&2
  exit 1
fi

if ! compgen -G '/var/lib/apt/lists/*_Packages*' >/dev/null; then
  echo "APT package metadata is missing; run 'sudo apt update' first." >&2
  exit 1
fi

mapfile -d '' -t PACKAGE_LISTS < <(
  find profiles -type f -name '*.list.chroot' -print0
)

if (( ${#PACKAGE_LISTS[@]} == 0 )); then
  echo "No live-build package lists were found." >&2
  exit 1
fi

package_output="$(
  awk '!/^[[:space:]]*(#|$)/ {print $1}' "${PACKAGE_LISTS[@]}" |
    sort -u
)"

if [[ -z "$package_output" ]]; then
  echo "No requested packages were found in the live-build package lists." >&2
  exit 1
fi

mapfile -t PACKAGES <<< "$package_output"

missing=()
for package in "${PACKAGES[@]}"; do
  if ! apt-cache show --no-all-versions "$package" >/dev/null 2>&1; then
    missing+=("$package")
  fi
done

if (( ${#missing[@]} > 0 )); then
  printf 'Packages unavailable from configured APT repositories:\n' >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "Confirmed ${#PACKAGES[@]} requested packages in configured APT repositories."
