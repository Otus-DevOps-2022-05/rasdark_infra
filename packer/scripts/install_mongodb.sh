#!/bin/bash
echo "Install MongoDB"
apt update && apt install -y mongodb
echo -e "\nStart and enable MongoDB"
systemctl start mongodb
systemctl enable mongodb

echo -e "\nCheck MongoDB status"
systemctl status mongodb
