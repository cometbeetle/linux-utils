#!/usr/bin/env bash

# Set up secure boot.
sudo kmodgenca -a --force
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

# Install akmods-keys.
git clone https://github.com/CheariX/silverblue-akmods-keys /tmp/akmods-keys
cd /tmp/akmods-keys
sudo bash setup.sh
sudo rpm-ostree install akmods-keys-*.rpm

# Install NVIDIA drivers.
sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau,nova_core --append=nvidia-drm.modeset=1 

# Reboot system.
systemctl reboot

