#!/bin/bash
set -e

curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
apt-get update
apt-get install wget jq npm yq vim -y

arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
    BINARY=yq_linux_amd64
elif [ "$arch" = "aarch64" -o "$arch" = "arm64" ]; then
    BINARY=yq_linux_arm64
else
    echo "Unsupported architecture: $arch"
    exit 1
fi
