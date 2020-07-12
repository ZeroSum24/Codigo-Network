#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root to run, use sudo $0"
    exit 1
fi

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  apt-get install -y python3-pip python3-dev
  curl -sL https://deb.nodesource.com/setup_10.x | bash -
  apt-get install -y nodejs
else
  echo "Installation script is only configured for Linux installation";
  exit 1
fi

# Install IPFS
apt-get install -y curl
if [ "$(arch)" == "x86_64" ]; then
  curl -X GET https://dist.ipfs.io/go-ipfs/v0.4.16/go-ipfs_v0.4.16_linux-386.tar.gz > ipfs.tar.gz
else
    echo "Installation script is not configured for this architecture";
    exit 1
fi

tar xvfz ipfs.tar.gz
cd go-ipfs
./install.sh
cd ../
rm -rf go-ipfs/
rm ipfs.tar.gz

# Install Pip dependencies
python3 -m pip install --upgrade pip
python3 -m pip install numpy matplotlib web3 ipfshttpclient pyqt5 py-solc-x

# Install Ganache
npm install -g ganache-cli
