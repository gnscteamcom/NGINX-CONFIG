#!/bin/bash

# Check sudo
if command -V sudo > /dev/null 2>&1; then
    sudo_found="yes"
    sudo_cmd="sudo "
fi

# Check root
printf "$(tput setaf 6)> $(tput setaf 7)Checking administrator user: "
if [ "`id -u`" = "0" ]; then
    sleep 2
    printf "$(tput setaf 6)ok$(tput setaf 7).\n"
    sleep 1
    sudo_cmd=""
else
    if [ "$sudo_found" = "yes" ]; then
        sleep 1
        printf "$(tput setaf 3)you need sudo rights. use: sudo sh start.sh.\033[0m\n"
        sleep 5
        exit 1
    else
        sleep 1
        printf "$(tput setaf 9)without root, sudo not found, leaving.\033[0m\n"
        sleep 3
        exit 1
    fi
fi

# Update system
${sudo_cmd}apt update && sudo apt -y upgrade

# Install prerequisits
${sudo_cmd}apt -y install curl gnupg2 ca-certificates lsb-release unzip sed wget

# Install nginx stable version
${sudo_cmd}echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
${sudo_cmd}curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
${sudo_cmd}apt update && sudo apt -y upgrade
${sudo_cmd}apt install nginx

# Install PHP-FPM stable for system
${sudo_cmd}apt install -y php-fpm
${sudo_cmd}apt install -y php-{bcmath,bz2,imap,intl,mbstring,mysqli,curl,zip,json,cli,gd,exif,xml}

# Obtain php version
php -r "echo PHP_MAJOR_VERSION,'.',PHP_MINOR_VERSION;" > phpversion
PHPV=$(cat phpversion)
${sudo_cmd}rm phpversion

# Obtain path dir
${sudo_cmd}echo "${PWD}" > pathdir
PATHDIR=$(cat pathdir)
${sudo_cmd}rm pathdir

# Edit version in config fastcgi
${sudo_cmd}sed -i "s/VERSIONPHP/${PHPV}/g" ${PATHDIR}/modules/setup/nginx/nginxconfig/php_fastcgi.conf

# Hide php version
${sudo_cmd}sed -i "s/expose_php = Off/expose_php = On/g" /etc/php/${PHPV}/fpm/php.ini

# Backup nginx
cd /etc/nginx
tar -czvf backup_nginx_$(date +'%F').tar.gz nginx.conf sites-available/ sites-enabled/

# Delete old archives
${sudo_cmd}rm -r /etc/nginx/sites-available
${sudo_cmd}rm -r /etc/nginx/sites-enabled
${sudo_cmd}rm /etc/nginx/nginx.conf
${sudo_cmd}rm /etc/nginx/mime.types

# Move new conf
${sudo_cmd}mv ${PATHDIR}/modules/setup/nginx/* /etc/nginx/

# Generate Diffie-Hellman keys
${sudo_cmd}openssl dhparam -out /etc/nginx/dhparam.pem 2048

# Install certbot
${sudo_cmd}apt-get install software-properties-common
${sudo_cmd}add-apt-repository universe
${sudo_cmd}add-apt-repository ppa:certbot/certbot
${sudo_cmd}apt-get update && sudo apt -y upgrade
${sudo_cmd}apt-get install certbot python-certbot-nginx python3-certbot-dns-cloudflare

# Create a common ACME-challenge directory (for Let's Encrypt)
${sudo_cmd}mkdir -p /var/www/_letsencrypt
${sudo_cmd}chown www-data /var/www/_letsencrypt

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
    ${sudo_cmd}wget https://raw.githubusercontent.com/Zonimi/NGINX-CONFIG/master/modules/menu.sh -O /bin/menu > /dev/null 2>&1
    ${sudo_cmd}chmod +x /bin/menu
    ${sudo_cmd}rm -r ${PATHDIR}
    clear
    menu
    ;;
    2|02)
    clear
    sleep 0.3
    ${sudo_cmd}wget https://raw.githubusercontent.com/Zonimi/NGINX-CONFIG/master/modules/menu.sh -O /bin/menu > /dev/null 2>&1
    ${sudo_cmd}chmod +x /bin/menu
    ${sudo_cmd}rm -r ${PATHDIR}
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
