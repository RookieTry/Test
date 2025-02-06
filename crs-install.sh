#!/bin/bash
# install-owasp-crs.sh

echo "Downloading and configuring OWASP CRS..."

# Download OWASP CRS
cd /opt
wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v4.10.0.tar.gz
tar -xzvf v4.10.0.tar.gz

# Move CRS to the NGINX folder
sudo mv coreruleset-4.10.0 /etc/nginx

# Configure ModSecurity to use OWASP CRS
#echo "include /etc/nginx/coreruleset/crs-setup.conf;" | sudo tee -a /etc/nginx/modsecurity.conf > /dev/null
#echo "include /etc/nginx/coreruleset/rules/*.conf;" | sudo tee -a /etc/nginx/modsecurity.conf > /dev/null

#Copy crs-setup

cp /etc/nginx/coreruleset/crs-setup.conf.example /etc/nginx/coreruleset/crs-setup.conf

echo "OWASP CRS installed and configured successfully."
