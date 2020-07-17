#!/usr/bin/env bash

if ! pgrep -f "ganache-cli" >> /dev/null
then
    echo "Error: You need to have a ganache-cli instance up to run the tests"
    exit 1
fi

if ! pgrep -f "ipfs daemon" >> /dev/null
then
    echo "Error: You need to have an ipfs daemon instance up to run the tests"
    exit 1
fi

# Setup
mkdir -p ./logs
if [ "$(uname)" == "Darwin" ]; then
  #  solcx.install_solc doesnt work for osx
  mkdir -p ~/.solcx/
  curl -O -L https://github.com/web3j/solidity-darwin-binaries/releases/download/0.4.25/solc_mac
  mv solc_mac ~/.solcx/solc-v0.4.25
  chmod +x ~/.solcx/solc-v0.4.25
else
  python3 -c 'import solcx; solcx.install_solc("v0.4.23")'
fi

# Run tests
python3 test/web_trust_test.py -v
python3 test/PriorityQ_Test.py -v
python3 test/fw_repo_test.py -v

# Clear temporary files
./clear_logs.sh
