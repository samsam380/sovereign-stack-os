#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  echo "Usage: $0 <desktop|server> [--uefi]" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 2
fi

readonly EDITION="$1"
case "$EDITION" in
  desktop|server) ;;
  *) usage; exit 2 ;;
esac

UEFI=false
if [[ "${2:-}" == "--uefi" ]]; then
  UEFI=true
elif [[ $# -eq 2 ]]; then
  usage
  exit 2
fi

for command in qemu-system-x86_64 qemu-img; do
  command -v "$command" >/dev/null 2>&1 \
    || { echo "Missing command: ${command}" >&2; exit 1; }
done

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mapfile -t ISO_IMAGES < <(find "${ROOT_DIR}/out" -maxdepth 1 -type f \
  -name "sovereign-stack-os-*-${EDITION}-amd64.iso" -print 2>/dev/null | sort)

if [[ "${#ISO_IMAGES[@]}" -ne 1 ]]; then
  echo "Expected exactly one ${EDITION} ISO in ${ROOT_DIR}/out; found ${#ISO_IMAGES[@]}." >&2
  exit 1
fi

readonly TEST_DIR="${ROOT_DIR}/build/qemu"
readonly DISK_PATH="${TEST_DIR}/${EDITION}.qcow2"
mkdir -p "$TEST_DIR"
if [[ ! -f "$DISK_PATH" ]]; then
  qemu-img create -f qcow2 "$DISK_PATH" 40G
fi

QEMU_ARGS=(
  -name "Sovereign Stack OS ${EDITION} test"
  -machine q35
  -m "$([[ "$EDITION" == desktop ]] && echo 4096 || echo 2048)"
  -smp 2
  -device virtio-vga
  -device virtio-net-pci,netdev=net0
  -netdev user,id=net0
  -drive "file=${DISK_PATH},if=virtio,format=qcow2"
  -cdrom "${ISO_IMAGES[0]}"
  -boot menu=on
)

if [[ -r /dev/kvm && -w /dev/kvm ]]; then
  QEMU_ARGS+=(-enable-kvm -cpu host)
fi

if [[ "$UEFI" == true ]]; then
  OVMF_CODE=""
  for candidate in /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_CODE.fd; do
    if [[ -r "$candidate" ]]; then
      OVMF_CODE="$candidate"
      break
    fi
  done
  [[ -n "$OVMF_CODE" ]] || { echo "OVMF firmware was not found." >&2; exit 1; }
  QEMU_ARGS+=(-drive "if=pflash,format=raw,readonly=on,file=${OVMF_CODE}")
fi

if [[ "$EDITION" == server ]]; then
  QEMU_ARGS+=(-nographic)
fi

exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
