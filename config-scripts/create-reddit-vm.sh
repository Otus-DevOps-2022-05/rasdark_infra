#!/bin/bash

echo -e "Don't forget to setup network"
yc compute instance create --name reddit-app
    --memory=4 --create-boot-disk name=reddit-full,size=12,image-family=reddit-full \
    --network-interface subnet-name=central-a,nat-ip-version=ipv4 \
    --metadata serial-port-enable=1 --ssh-key ~/.ssh/appuser.pub
