#!/bin/bash

# Install scarb
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# Install starkli
curl https://get.starkli.sh | sh 
# Update starkli
~/.starkli/bin/starkliup

# Install Dojo
curl -L https://install.dojoengine.org | bash
# Update Dojo
~/.dojo/bin/dojoup