#!/bin/bash
set -ex  # will exit on any error and print all commands

# Function to install packages on Enterprise Linux (CentOS, RHEL)
install_enterprise_linux() {
    yum install -y epel-release
    yum update -y  # Update the system
    yum groupinstall -y "Development Tools"
    yum install -y cmake git libusb-devel hdf5-devel
}

# Function to install packages on Debian-based systems (Debian, Ubuntu)
install_debian() {
    apt update -y  # Update the system
    apt install -y build-essential cmake git libusb-1.0-0-dev libhdf5-dev
}

# Function to install packages on Alpine Linux
install_alpine() {
    apk update  # Update the system
    apk add --no-cache build-base cmake git libusb-dev hdf5-dev
}

# Determine the Linux distribution and install packages accordingly
if [ -f "/etc/redhat-release" ]; then
    # Enterprise Linux (CentOS, RHEL)
    install_enterprise_linux
elif [ -f "/etc/debian_version" ]; then
    # Debian-based distribution (Debian, Ubuntu)
    install_debian
elif grep -qi alpine /etc/os-release; then
    # Alpine Linux
    install_alpine
else
    echo "Unsupported distribution"
    exit 1
fi

# Clone and build LimeSuite
rm -rf LimeSuite
git clone https://github.com/myriadrf/LimeSuite.git
cd LimeSuite/build || exit
cmake ../ -DENABLE_GUI=OFF
make -j$(nproc)
make install
ldconfig
