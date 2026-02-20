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

# Fix Vulkan issue on NVIDIA GPUs.
init_hooks="echo 'export VK_ICD_FILENAMES=/run/host/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json' >> ~/.bashrc"

# Add the Visual Studio Code repository.
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Install standard packages via DNF.
packages=(
    # General requirements.
    gcc
    gcc-c++
    gcc-gfortran
    gdb
    cmake
    make
    code
    wayland-devel
    alsa-lib-devel
    libudev-devel
    libxkbcommon
    vulkan-tools
    mesa-libGL
    openssl-devel  # helps with Spack
    python3-devel  # helps with Spack
    tcl-devel      # helps with Spack
    clingo         # helps with Spack
    Lmod           # HPC + Spack
    pandoc
    R
    rstudio-desktop
    # Additional Spack-related requirements.
    file
    bzip2
    ca-certificates
    git
    gzip
    patch
    python3
    tar
    unzip
    xz
    zstd
)
dnf copr enable -y iucar/rstudio
dnf install -y "${packages[@]}"

# Install Spack.
git clone --depth=2 https://github.com/spack/spack.git /opt/spack
. /opt/spack/share/spack/setup-env.sh
spack config --scope system add modules:default:enable:[tcl]
spack external find --scope system --all
spack compiler find --scope system
spack module tcl refresh -y
cat <<EOF > /etc/profile.d/spack-setup-env.sh
#!/usr/bin/env bash
. /opt/spack/share/spack/setup-env.sh
EOF

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

# Install Rust (do not use Spack).
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
