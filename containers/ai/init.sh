#!/usr/bin/env bash

# NOTE: This script assumes the distrobox instance will supply
# the HOST_UID, HOST_GID, and HOST_HOME environment variables.
# Ensure these are properly inserted by the host system.

set -e

# =======================================================================

SENTINEL="$HOME/.distrobox-initialized"

# Do not execute the script if the container has already been initialized.
if [[ -f "$SENTINEL" ]]; then
    exit 0
fi
touch "$SENTINEL"

# =======================================================================

# Use setup directory.
mkdir -p /tmp/setup && cd /tmp/setup

# Fix Vulkan issue on NVIDIA GPUs.
init_hooks="echo 'export VK_ICD_FILENAMES=/run/host/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json' >> ~/.bashrc"

# Install standard packages via DNF.
dnf install -y \
    fuse \
    fuse-libs \
    nspr \
    nss \
    dbus-libs \
    atk \
    at-spi2-atk \
    gtk3

# Install uv.
curl -LsSf https://astral.sh/uv/install.sh | sh

# Allow launching apps on the host system from within the container.
ln -sf /usr/bin/distrobox-host-exec /usr/bin/flatpak
ln -sf /usr/bin/distrobox-host-exec /usr/bin/xdg-open

# Clean DNF.
dnf clean all

# Ensure proper container home directory permissions (must be done last).
chown -R $HOST_UID:$HOST_GID $HOME
