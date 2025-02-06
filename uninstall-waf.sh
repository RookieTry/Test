#!/bin/bash
echo "Stopping NGINX..."
sudo systemctl stop nginx

echo "Removing NGINX and dependencies..."
sudo apt remove --purge -y nginx nginx-common nginx-core
sudo apt autoremove -y

echo "Deleting NGINX configuration and logs..."
sudo rm -rf /etc/nginx /var/log/nginx /var/lib/nginx

echo "Removing ModSecurity..."
sudo rm -rf /opt/modsecurity /opt/modsecurity-nginx
sudo rm -rf /etc/nginx/modsecurity.conf
sudo apt remove --purge -y libmodsecurity3

echo "Cleaning up system..."
sudo apt autoremove -y
sudo apt clean

echo "Uninstallation complete. System is clean."
