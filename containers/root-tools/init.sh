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

# Add .bashrc.d directory.
mkdir -p ~/.bashrc.d

# Install standard packages via DNF.
dnf install -y \
    wireshark

# Allow launching apps on the host system from within the container.
ln -sf /usr/bin/distrobox-host-exec /usr/bin/flatpak
ln -sf /usr/bin/distrobox-host-exec /usr/bin/xdg-open

# Clean DNF.
dnf clean all

# Ensure proper container home directory permissions (must be done last).
chown -R $HOST_UID:$HOST_GID $HOME
