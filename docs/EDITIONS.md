# Editions

## Desktop

The Desktop edition is the ordinary PC experience:

- KDE Plasma 6
- SDDM login manager
- NetworkManager
- Firefox ESR
- Flatpak integration, without a mandatory third-party remote
- KeePassXC and standard KDE utilities
- Calamares graphical installer
- dark Sovereign Stack visual defaults

It does not enable an SSH server by default.

## Server

The Server edition contains no graphical desktop packages. It provides:

- console login and text-mode installer
- OpenSSH server
- NetworkManager command-line tools
- nftables/UFW tooling
- fail2ban configuration for SSH
- common diagnostic and storage utilities
- optional Podman container runtime

Password authentication remains available during the developer preview so a newly installed machine is not accidentally inaccessible. Root SSH login is disabled. Operators should add an SSH key and then disable password authentication.

## Moving between roles

A Server installation can later receive KDE using Debian packages, and a Desktop installation can host server software. Nevertheless, use the dedicated image where possible: it gives a smaller attack surface and makes the machine's intended role obvious.

The project may eventually offer additional package roles—Bitcoin node, development workstation, local AI, and recovery—but those should remain optional layers rather than separate operating systems.
