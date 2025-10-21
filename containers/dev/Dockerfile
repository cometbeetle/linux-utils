FROM fedora-toolbox:latest

WORKDIR /tmp/setup

# Install simple packages via DNF.
RUN sudo dnf check-update && \
    sudo dnf install -y \
        gcc \ 
        gcc-c++ \
        cmake \
        make \
        wayland-devel \
        alsa-lib-devel \
        libudev-devel \
        libxkbcommon \
        vulkan-tools \
        uv \
        rust \
        cargo \
        rustfmt \
        rust-src

# Run special installation scripts.
COPY install-custom.sh .
RUN chmod +x install-custom.sh && ./install-custom.sh

RUN sudo dnf clean all
