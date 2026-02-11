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
dnf copr enable -y iucar/rstudio
dnf install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    gdb \
    cmake \
    make \
    wayland-devel \
    alsa-lib-devel \
    libudev-devel \
    libxkbcommon \
    vulkan-tools \
    pandoc \
    R \
    rstudio-desktop

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
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Add the Intel oneAPI repository.
cat <<EOF > /etc/yum.repos.d/oneAPI.repo
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

# Install the new packages.
dnf install -y temurin-21-jdk code intel-hpckit

# Install JetBrains Toolbox.
wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.2.0.65851.tar.gz"
mkdir /opt/jetbrains-toolbox && tar -xzf jetbrains-toolbox-*.tar.gz -C /opt/jetbrains-toolbox --strip-components 1
rm *.tar.gz
mkdir /opt/launchers
cat <<EOF > /opt/launchers/jetbrains-toolbox.sh
#!/usr/bin/env bash
/opt/jetbrains-toolbox/bin/jetbrains-toolbox >/dev/null 2>&1 &
EOF
chmod +x /opt/launchers/jetbrains-toolbox.sh
ln -sf /opt/launchers/jetbrains-toolbox.sh /usr/local/bin/jetbrains-toolbox

# Install uv.
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Rust.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Allow launching apps on the host system from within the container.
ln -sf /usr/bin/distrobox-host-exec /usr/bin/flatpak
ln -sf /usr/bin/distrobox-host-exec /usr/bin/xdg-open

# Link Git config & credentials to container.
[ -e $HOST_HOME/.gitconfig ] || { touch $HOST_HOME/.gitconfig && chown $HOST_UID:$HOST_GID $HOST_HOME/.gitconfig; }; ln -sf $HOST_HOME/.gitconfig ~
[ -e $HOST_HOME/.git-credentials ] || { touch $HOST_HOME/.git-credentials && chmod 600 $HOST_HOME/.git-credentials && chown $HOST_UID:$HOST_GID $HOST_HOME/.git-credentials; }; ln -sf $HOST_HOME/.git-credentials ~

# Link .netrc to container.
[ -e $HOST_HOME/.netrc ] || { touch $HOST_HOME/.netrc && chmod 600 $HOST_HOME/.netrc && chown $HOST_UID:$HOST_GID $HOST_HOME/.netrc; }; ln -sf $HOST_HOME/.netrc ~

# Clean DNF.
dnf clean all

# Ensure proper container home directory permissions (must be done last).
chown -R $HOST_UID:$HOST_GID $HOME
