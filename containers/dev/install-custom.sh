#!/bin/bash

# Use setup directory from Dockerfile.
cd /tmp/setup

# Add the Adoptium repository.
cat <<EOF > /etc/yum.repos.d/adoptium.repo
[Adoptium]
name=Adoptium
baseurl=https://packages.adoptium.net/artifactory/rpm/${DISTRIBUTION_NAME:-$(. /etc/os-release; echo $ID)}/\$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
EOF

# Add the Visual Studio Code repository.
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Install the new packages.
sudo dnf check-update
sudo dnf install -y temurin-21-jdk code

# Install JetBrains Toolbox.
wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.2.0.65851.tar.gz"
sudo tar -xzf jetbrains-toolbox-*.tar.gz -C /opt
rm *.tar.gz
sudo mkdir /opt/launchers
cat <<EOF | sudo tee /opt/launchers/jetbrains-toolbox.sh > /dev/null
#!/usr/bin/env bash
/opt/jetbrains-toolbox-*/bin/jetbrains-toolbox >/dev/null 2>&1 &
EOF
sudo chmod +x /opt/launchers/jetbrains-toolbox.sh
sudo ln -sf /opt/launchers/jetbrains-toolbox.sh /usr/local/bin/jetbrains-toolbox
