#!/bin/bash
# modsecurity-nginx-connector.sh
#

echo "Checking for ModSecurity-NGINX connector..."
if [ -d /opt/modsecurity-nginx ]; then
    echo "Connector already exists. Skipping download."
else
    echo "Downloading ModSecurity-NGINX connector..."
    cd /opt && git clone https://github.com/owasp-modsecurity/modsecurity-nginx.git
     cd /opt/nginx-1.24.0
    ./configure --with-compat --add-dynamic-module=/opt/modsecurity-nginx
    make
    make modules
    echo "Connector downloaded."
   
fi
