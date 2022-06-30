#!/bin/bash
echo "Install MongoDB"
apt update -y
sleep 1m
apt install -y mongodb
echo -e "\nStart and enable MongoDB"
systemctl start mongodb
systemctl enable mongodb

echo -e "\nCheck MongoDB status"
systemctl status mongodb
