# Roadmap

## 0.1 — Foundation

- Debian 13 Stable base
- KDE Plasma Desktop and console Server profiles
- hybrid BIOS/UEFI images
- common branding and diagnostic commands
- validation workflow
- manually triggered GitHub ISO builds
- QEMU and physical-hardware test instructions

## 0.2 — Installer and visual identity

- complete Calamares rebranding
- installer encryption guidance
- signed boot-path verification on representative PCs
- graphical first-run disclosure of updates, firmware, and optional services

## 0.3 — Sovereign package channel

- minimal APT repository for project-owned packages only
- offline root key and rotatable release key
- documented signing ceremony and disaster recovery
- automated configuration migrations

## 0.4 — Verifiable builds

- snapshot-aware build inputs
- SBOM and package manifest per image
- SLSA-style provenance record
- two independent builders comparing artifacts

## 1.0 — Supported release

- tested upgrade path
- published hardware matrix
- signed release and recovery images
- security-reporting channel
- maintenance and end-of-life policy

## Later profiles

Bitcoin-node, developer, local-AI, and recovery roles may be delivered as optional metapackages. They should not enlarge the default trusted computing base for every user.
