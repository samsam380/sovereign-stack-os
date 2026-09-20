FROM debian:13-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        bash \
        ca-certificates \
        debootstrap \
        dosfstools \
        git \
        grub-efi-amd64-bin \
        grub-pc-bin \
        isolinux \
        live-build \
        mtools \
        python3 \
        python3-yaml \
        rsync \
        shellcheck \
        squashfs-tools \
        syslinux-common \
        xorriso \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENTRYPOINT ["./scripts/build.sh"]
