#!/usr/bin/env bash

# Update system.
sudo rpm-ostree update

# Install necessary packages and enable RPM Fusion.
sudo rpm-ostree install rpmdevtools akmods
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Reboot.
systemctl reboot

