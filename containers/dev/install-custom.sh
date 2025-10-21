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

# Install JetBrains IDEs.
PYCHARM_VERSION="2025.2.3"
INTELLIJ_VERSION="2025.2.3"
RUSTROVER_VERSION="2025.2.3"
CLION_VERSION="2025.2.3"
wget "https://download.jetbrains.com/python/pycharm-${PYCHARM_VERSION}.tar.gz"
wget "https://download.jetbrains.com/idea/ideaIU-${INTELLIJ_VERSION}.tar.gz"
wget "https://download.jetbrains.com/rustrover/RustRover-${RUSTROVER_VERSION}.tar.gz"
wget "https://download.jetbrains.com/cpp/CLion-${CLION_VERSION}.tar.gz"
sudo tar -xzvf pycharm-*.tar.gz -C /opt
sudo tar -xzvf ideaIU-*.tar.gz -C /opt
sudo tar -xzvf RustRover-*.tar.gz -C /opt
sudo tar -xzvf CLion-*.tar.gz -C /opt
rm *.tar.gz
sudo mkdir /opt/jb_launchers
cat <<EOF | sudo tee /opt/jb_launchers/pycharm.sh > /dev/null
#!/bin/bash
/opt/pycharm-*/bin/pycharm >/dev/null 2>&1 &
EOF
cat <<EOF | sudo tee /opt/jb_launchers/intellij.sh > /dev/null
#!/bin/bash
/opt/idea-IU-*/bin/idea >/dev/null 2>&1 &
EOF
cat <<EOF | sudo tee /opt/jb_launchers/rustrover.sh > /dev/null
#!/bin/bash
/opt/RustRover-*/bin/rustrover >/dev/null 2>&1 &
EOF
cat <<EOF | sudo tee /opt/jb_launchers/clion.sh > /dev/null
#!/bin/bash
/opt/clion-*/bin/clion >/dev/null 2>&1 &
EOF
sudo chmod +x /opt/jb_launchers/*.sh
sudo ln -sf /opt/jb_launchers/pycharm.sh /usr/local/bin/pycharm
sudo ln -sf /opt/jb_launchers/intellij.sh /usr/local/bin/intellij
sudo ln -sf /opt/jb_launchers/rustrover.sh /usr/local/bin/rustrover
sudo ln -sf /opt/jb_launchers/clion.sh /usr/local/bin/clion
