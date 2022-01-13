#!/bin/bash

echo "nameserver 192.168.0.1" >> /etc/resolv.conf
echo "HOLA MUNDO" > /hello
sudo apt update
sudo apt install net-tools -y