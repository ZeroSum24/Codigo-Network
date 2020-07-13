#!/usr/bin/env bash

function setup_macos() {
  echo Installing nodejs
  # Install only if not installed
  brew list node > /dev/null || brew install node
  echo Installing python3
  # installs both pip3 and python3
  brew list python3 > /dev/null || brew install python3
  echo Checking if curl is installed
  command -v curl > /dev/null || brew install curl
  if [ "$(uname -m)" == "x86_64" ]; then
    echo Downloading IPFS
    curl https://dist.ipfs.io/go-ipfs/v0.6.0/go-ipfs_v0.6.0_darwin-amd64.tar.gz > ipfs.tar.gz
  else
    echo "Installation script is not configured for this architecture";
    exit 1
  fi
}

function setup_ipfs_linux() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script requires root to run, use sudo $0"
    exit 1
  fi
  apt-get install -y python3-pip python3-dev
  curl -sL https://deb.nodesource.com/setup_10.x | bash -
  apt-get install -y nodejs
  apt-get install -y curl
  if [ "$(arch)" == "x86_64" ]; then
    curl -X GET https://dist.ipfs.io/go-ipfs/v0.4.16/go-ipfs_v0.4.16_linux-386.tar.gz > ipfs.tar.gz
  else
      echo "Installation script is not configured for this architecture";
      exit 1
  fi
}

if [ "$(uname)" == "Darwin" ]; then
  setup_macos
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  setup_ipfs_linux

fi

tar xvfz ipfs.tar.gz
cd go-ipfs || exit 1
./install.sh
cd ../
rm -rf go-ipfs/
rm ipfs.tar.gz

# Install Pip dependencies
python3 -m pip install --upgrade pip
python3 -m pip install numpy matplotlib web3 ipfshttpclient pyqt5 py-solc-x

# Install Ganache
npm install -g ganache-cli
