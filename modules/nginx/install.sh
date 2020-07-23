#!/bin/bash

# Update system
sudo apt update && sudo apt -y upgrade

# Install prerequisits
sudo apt -y install curl gnupg2 ca-certificates lsb-release unzip sed

# Install nginx stable version
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt update
sudo apt install nginx

# Install PHP-FPM stable for system
sudo apt -y php-fpm
sudo apt -y php-{bcmath,bz2,imap,intl,mbstring,mysqli,curl,zip,json,cli,gd,exif,xml}

# Obtain php version
php -r "echo PHP_MAJOR_VERSION,'.',PHP_MINOR_VERSION;" > phpversion
PHPV=$(cat phpversion)
sudo rm phpversion

# Hide php version
sudo sed -i "s/expose_php = Off/expose_php = On/g" /etc/php/${PHPV}/fpm/php.ini

# Backup nginx
cd /etc/nginx
tar -czvf backup_nginx_$(date +'%F').tar.gz nginx.conf sites-available/ sites-enabled/

# Delete old archives
rm -r /etc/nginx/sites-available
em -r /etc/nginx/sites-enabled
rm /etc/nginx/nginx.conf

# Move new conf
mv /tmp/NGINX-CONFIG/nginx/* /etc/nginx/

# Generate Diffie-Hellman keys
openssl dhparam -out /etc/nginx/dhparam.pem 2048

# Install certbot
sudo apt install certbot

# Create a common ACME-challenge directory (for Let's Encrypt)
mkdir -p /var/www/_letsencrypt
chown www-data /var/www/_letsencrypt
