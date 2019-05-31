#!/usr/bin/env bash
if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  apt install python3-pip python3-dev
  curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
  apt-get install -y nodejs npm
else
  echo "Installation script is only configured for Linux installation";
  exit 1
fi

# Install IPFS
apt-get install curl
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
pip3 install numpy matplotlib web3 ipfshttpclient pyqt5
pip3 install py-solc-x
# Install Ganache
npm install -g ganache-cli
