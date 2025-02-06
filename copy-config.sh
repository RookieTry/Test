#!/bin/bash
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
