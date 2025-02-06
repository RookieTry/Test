# Add ModSecurity module to nginx.conf if not already present
#if ! grep -q "load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf; then
   # sudo sed -i '/^http {/a \
  #  load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
 #   echo "Added ModSecurity module to nginx.conf"
#else
 #   echo "ModSecurity module already present in nginx.conf"
#fi

#!/bin/bash
# nginx-install.sh

echo "Checking for NGINX installation..."
if nginx -v 2>/dev/null; then
    echo "NGINX is already installed. Skipping installation."
else
    echo "Installing NGINX..."
    sudo apt update
    #sudo apt install -y nginx
    cd /opt && wget https://nginx.org/download/nginx-1.24.0.tar.gz
 tar -xzvf nginx-1.24.0.tar.gz
 cd /opt/nginx-1.24.0
 ./configure
 make
 make install
    echo "NGINX installed successfully."
fi
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
# modsecurity-nginx-connector.sh

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
# copy-configs.sh

echo "Copying ModSecurity and NGINX configuration files..."

# Ensure the modules directory exists
sudo mkdir -p /etc/nginx/modules-enabled

# Copy ModSecurity module to the correct location
sudo cp /opt/nginx-1.24.0/objs/ngx_http_modsecurity_module.so /etc/nginx/modules-enabled/

# Copy recommended ModSecurity config
sudo cp /opt/modsecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.conf

# Copy unicode mapping file (required for ModSecurity)
sudo cp /opt/modsecurity/unicode.mapping /etc/nginx/

echo "Configuration files copied successfully."
# nginx-config.sh

echo "Configuring NGINX to use ModSecurity..."
# Check if ModSecurity module is already in nginx.conf
if ! grep -q "load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf; then
    echo "Adding ModSecurity module to nginx.conf..."
    
    # Add load_module directive at the top of the nginx.conf file, before the http block
    sudo sed -i '1i load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
    echo "ModSecurity module added to nginx.conf"
else
    echo "ModSecurity module already present in nginx.conf"
fi

#if ! grep -q "load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf; then
    #sudo sed -i '/^http {/a \
    #load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
    #echo "Added ModSecurity module to nginx.conf"
#else
   # echo "ModSecurity module already present in nginx.conf"
#fi

# Define variables
MODSEC_CONF="/etc/nginx/nginx.conf"

# Check if ModSecurity settings are already in the server block
if grep -q "modsecurity on;" $MODSEC_CONF; then
    echo "ModSecurity is already enabled in the NGINX server block. Skipping modification."
else
    echo "Adding ModSecurity configuration to NGINX server block..."

    # Insert ModSecurity settings inside the existing server block
    sudo sed -i '/server {/a \
        modsecurity on;\n\
        modsecurity_rules_file /etc/nginx/modsecurity.conf;' $MODSEC_CONF


    echo "ModSecurity configuration added."
fi

echo "NGINX configuration updated."

# Change SecRuleEngine from DetectionOnly to On in modsecurity.conf
sudo sed -i 's/^SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsecurity.conf

# Append OWASP CRS includes to the end of modsecurity.conf if not already present
if ! grep -q "include /etc/nginx/coreruleset/crs-setup.conf" /etc/nginx/modsecurity.conf; then
    sudo tee -a /etc/nginx/modsecurity.conf > /dev/null <<EOF

include /etc/nginx/coreruleset/crs-setup.conf
include /etc/nginx/coreruleset/rules/*.conf
EOF
    echo "OWASP Core Rule Set appended to modsecurity.conf."
else
    echo "OWASP Core Rule Set already present in modsecurity.conf. Skipping modification."
fi

#sudo sed -i 's/^SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsecurity.conf

#sudo tee -a /etc/nginx/modsecurity.conf > /dev/null <<EOF

#include /etc/nginx/coreruleset-4.10.0/crs-setup.conf
#include /etc/nginx/coreruleset-4.10.0/rules/*.conf
#EOF
