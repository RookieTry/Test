#!/bin/bash
# nginx-install.sh
#Checks for package-based installation. But really, you guys should know if you have nginx or not
echo "Checking for NGINX installation..."
if nginx -v 2>/dev/null; then
    echo "NGINX is already installed. Skipping installation."
else
    echo "Installing NGINX..."
    sudo apt update
    cd /opt && wget https://nginx.org/download/nginx-1.24.0.tar.gz
 tar -xzvf nginx-1.24.0.tar.gz
 cd /opt/nginx-1.24.0
 ./configure
 make
 make install
    echo "NGINX installed successfully."
fi
