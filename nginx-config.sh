#!/bin/bash
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

