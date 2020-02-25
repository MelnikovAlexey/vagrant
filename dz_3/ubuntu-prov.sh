#!/usr/bin/env bash
sudo apt update -y
sudo apt install nginx-full -y
sudo apt install mc -y

if test -f "/etc/apparmor.d/usr.sbin.nginx"; then
	sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.nginx
	sudo systemctl restart nginx
fi

