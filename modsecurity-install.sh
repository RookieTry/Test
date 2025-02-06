#!/bin/bash
# modsecurity-install.sh


echo "Checking for ModSecurity installation..."
if [ -f /usr/local/modsecurity/ ]; then
    echo "ModSecurity is already installed. Skipping installation."
else
    echo "Installing ModSecurity..."
    sudo apt install -y gcc make build-essential autoconf automake libtool \
    libcurl4-openssl-dev liblua5.3-dev libfuzzy-dev ssdeep gettext pkg-config \
    libpcre3 libpcre3-dev libxml2 libxml2-dev libgeoip-dev libyajl-dev doxygen \
    libpcre2-16-0 libpcre2-dev git wget tar docker.io
    sudo apt-get update
    sudo apt-get install zlib1g-dev

    cd /opt && sudo git clone https://github.com/owasp-modsecurity/modsecurity.git
    cd /opt/modsecurity
    git submodule init
    git submodule update
    ./build.sh
    ./configure
    make
    sudo make install
    echo "ModSecurity installed successfully."
fi
