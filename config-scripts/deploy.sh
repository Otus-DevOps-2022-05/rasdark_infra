#!/bin/bash
sudo apt-get install -y git
sudo git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
sudo puma -d
