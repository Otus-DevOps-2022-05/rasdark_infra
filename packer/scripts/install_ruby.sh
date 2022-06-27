#!/bin/bash
echo "Install ruby"
apt update && apt install -y ruby-full ruby-bundler build-essential
echo -e "\n\nCheck versions of ruby and bundler"
ruby -v
bundler -v
