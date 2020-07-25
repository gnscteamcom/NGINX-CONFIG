#!/bin/bash

# Update system
sudo apt update && sudo apt -y upgrade

# Install prerequisits
sudo apt -y install curl gnupg2 ca-certificates lsb-release unzip sed

# Install nginx stable version
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt update && sudo apt -y upgrade
sudo apt install nginx

# Install PHP-FPM stable for system
sudo apt install -y php-fpm
sudo apt install -y php-{bcmath,bz2,imap,intl,mbstring,mysqli,curl,zip,json,cli,gd,exif,xml}

# Obtain php version
php -r "echo PHP_MAJOR_VERSION,'.',PHP_MINOR_VERSION;" > phpversion
PHPV=$(cat phpversion)
sudo rm phpversion

# Obtain path dir
echo "${PWD}" > pathdir
PATHDIR=$(cat pathdir)
sudo rm pathdir

# Edit version in config fastcgi
sudo sed -i "s/VERSIONPHP/${PHPV}/g" ${PATHDIR}/modules/setup/nginx/nginxconfig/php_fastcgi.conf

# Hide php version
sudo sed -i "s/expose_php = Off/expose_php = On/g" /etc/php/${PHPV}/fpm/php.ini

# Backup nginx
cd /etc/nginx
tar -czvf backup_nginx_$(date +'%F').tar.gz nginx.conf sites-available/ sites-enabled/

# Delete old archives
rm -r /etc/nginx/sites-available
rm -r /etc/nginx/sites-enabled
rm /etc/nginx/nginx.conf
rm /etc/nginx/mime.types

# Move new conf
mv ${PATHDIR}/modules/setup/nginx/* /etc/nginx/

# Generate Diffie-Hellman keys
openssl dhparam -out /etc/nginx/dhparam.pem 2048

# Install certbot
# sudo apt -y install certbot

# Create a common ACME-challenge directory (for Let's Encrypt)
mkdir -p /var/www/_letsencrypt
chown www-data /var/www/_letsencrypt

language (){
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "\e[1;3;31m[\e[1;3;32m+\e[1;3;31m] \e[1;3;33mSelect your language\e[0m"
printf "\n"
echo "  \e[1;3;31m[\e[1;3;36m01\e[1;3;31m] \e[1;3;33mPortuguês (Brazil)              
  \e[1;3;31m[\e[1;3;36m02\e[1;3;31m] \e[1;3;33mEnglish"
printf "\n"
read -p "$(tput setaf 6)> $(tput setaf 7)Your language: $(tput setaf 6)" language
echo -n "$(tput setaf 7)"
case "$language" in
    1|01)
    clear
    sleep 0.3
    wget https://raw.githubusercontent.com/Zonimi/NGINX-CONFIG/master/modules/menu.sh -O /bin/menu > /dev/null 2>&1
    chmod +x /bin/menu
    rm -r ${PATHDIR}
    clear
    menu
    ;;
    2|02)
    clear
    sleep 0.3
    wget https://raw.githubusercontent.com/Zonimi/NGINX-CONFIG/master/modules/menu.sh -O /bin/menu > /dev/null 2>&1
    chmod +x /bin/menu
    rm -r ${PATHDIR}
    clear
    menu
    ;;
    *)
    echo "  \033[1;31mInvalid!\033[0m"
    sleep 1
    clear
    sleep 0.3
    language
esac
}
language
