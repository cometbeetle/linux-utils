#!/usr/bin/env bash

# Unlock rpm-ostree for future upgrades.
sudo rpm-ostree update \
    --uninstall rpmfusion-free-release \
    --uninstall rpmfusion-nonfree-release \
    --install rpmfusion-free-release \
    --install rpmfusion-nonfree-release

# Reboot system.
systemctl reboot
