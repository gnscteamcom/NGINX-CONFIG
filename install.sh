#!/bin/bash

# Update system
sudo apt update && sudo apt -y upgrade

# Install prerequisits
sudo apt -y install curl gnupg2 ca-certificates lsb-release unzip

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



