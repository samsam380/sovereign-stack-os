# Testing

## 1. Verify the download

From the directory containing the ISO and checksum:

```bash
sha256sum --check sovereign-stack-os-*.iso.sha256
```

This detects corruption. Until releases are signed, obtain the checksum through a separately trusted channel when possible.

## 2. Inspect the ISO

```bash
./scripts/inspect-iso.sh out/sovereign-stack-os-0.1.0-dev-desktop-amd64.iso
```

The script checks the file hash, ISO metadata, expected live filesystem, and boot files.

## 3. QEMU smoke test

Install QEMU and optionally OVMF, then run:

```bash
./scripts/qemu-test.sh desktop
./scripts/qemu-test.sh server --uefi
```

Test all of the following before physical installation:

- BIOS boot
- UEFI boot
- live session reaches KDE or a console, depending on edition
- wired and Wi-Fi networking
- installer starts
- encrypted installation into a disposable virtual disk
- reboot into the installed system
- local console login displays the Sovereign Stack welcome artwork correctly in a UTF-8, 80-column terminal
- interactive SSH login displays the same artwork once (Server, or Desktop with an SSH server installed and enabled)
- Debian security repositories are enabled
- `sudo sovereign-info` reports the expected edition
- `sudo apt update && sudo apt upgrade` succeeds

## 4. Spare-PC test plan

Back up the entire target PC before testing. Disconnect unrelated storage devices during installation.

Record:

- manufacturer and exact model
- CPU, GPU, Wi-Fi, Ethernet, audio, storage controller
- firmware mode and Secure Boot state
- ISO checksum
- tested commit SHA
- boot, suspend, resume, shutdown, audio, display, network, Bluetooth, and installer results

Start with automatic partitioning on an empty disk. Test dual boot only after single-disk installation is reliable.

## Known developer-preview limitations

- no signed Sovereign Stack release manifest yet
- Calamares still inherits portions of Debian's installer branding
- no hardware certification matrix
- no automated post-install end-to-end test
- no independent reproducible-build comparison
