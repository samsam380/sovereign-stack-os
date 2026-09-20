#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  echo "Usage: $0 <desktop|server|all>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

readonly SELECTION="$1"
case "$SELECTION" in
  desktop|server) EDITIONS=("$SELECTION") ;;
  all) EDITIONS=(desktop server) ;;
  *)
    usage
    exit 2
    ;;
esac

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BUILD_ROOT="$(realpath -m "${ROOT_DIR}/build")"

for edition in "${EDITIONS[@]}"; do
  target="$(realpath -m "${ROOT_DIR}/build/${edition}")"
  if [[ "$target" != "${BUILD_ROOT}/${edition}" || "$target" == "/" ]]; then
    echo "Refusing unsafe clean target: ${target}" >&2
    exit 1
  fi
  if [[ -d "$target" ]]; then
    if command -v lb >/dev/null 2>&1; then
      (cd "$target" && lb clean --purge >/dev/null 2>&1) || true
    fi
    rm -rf -- "$target"
    echo "Removed ${target}"
  fi
done

if [[ "$SELECTION" == "all" && -d "${ROOT_DIR}/out" ]]; then
  readonly OUT_PATH="$(realpath -m "${ROOT_DIR}/out")"
  if [[ "$OUT_PATH" != "$(realpath -m "${ROOT_DIR}")/out" || "$OUT_PATH" == "/" ]]; then
    echo "Refusing unsafe output clean target: ${OUT_PATH}" >&2
    exit 1
  fi
  rm -rf -- "$OUT_PATH"
  echo "Removed ${OUT_PATH}"
fi
