#!/bin/bash
echo "$(tput civis)"
# Check sudo
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
if command -V sudo > /dev/null 2>&1; then
    sudo_found="yes"
    sudo_cmd="sudo "
fi

# Check root
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
printf "$(tput setaf 6)> $(tput setaf 7)Checking administrator user... "
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
echo "$(tput cnorm)"
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

# Settings for CloudFlare
cloudflareconfig () {
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "$(tput setaf 6)+ $(tput setaf 7)Some scripts depend on CloudFlare,\n  it is important that you enable this."
echo -n "$(tput setaf 7)"
echo "\n$(tput setaf 6)! $(tput setaf 8)Answer \"yes\" or \"no\"."
read -p "$(tput setaf 6)> $(tput setaf 7)Do you want to configure CloudFlare: $(tput setaf 6)" cloudflare
echo -n "$(tput setaf 7)"

if [ "${cloudflare}" = "" -o "${cloudflare}" = "no" ]; then

${sudo_cmd}mkdir /root/.secrets
sudo chmod 0700 /root/.secrets/
touch /root/.secrets/cloudflare.ini

echo "dns_cloudflare_email = \"youremail@example.com\"" > /root/.secrets/cloudflare.ini
echo "dns_cloudflare_api_key = \"123456789\"" >> /root/.secrets/cloudflare.ini

sudo chmod 0400 /root/.secrets/cloudflare.ini

else
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "\e[1;3;31m[\e[1;3;32m+\e[1;3;31m] \e[1;3;33mFollow the steps below to set up your Cloud Flare.\e[0m"
printf "\n"

echo "$(tput setaf 6)1. $(tput setaf 7)Go to $(tput setaf 622)cloudflare.com $(tput setaf 7)and connect with your account or create."
echo "$(tput setaf 6)2. $(tput setaf 7)Add your website and point the DNS as instructed by Cloud Flare."
echo "$(tput setaf 6)3. $(tput setaf 7)On the Cloud Flare dashboard, go to \"$(tput setaf 622)SSL/TLS$(tput setaf 7)\" and leave it below;"
echo "\n    $(tput setaf 229)SSL/TLS encryption:       $(tput setaf 7)Full (strict)"
echo "    $(tput setaf 229)Always Use HTTPS:         $(tput setaf 7)Off"
echo "    $(tput setaf 229)HTTP Strict Transport:    $(tput setaf 7)Disable"
echo "    $(tput setaf 229)Minimum TLS Version:      $(tput setaf 7)TLS 1.2"
echo "    $(tput setaf 229)Opportunistic Encryption: $(tput setaf 7)Off"
echo "    $(tput setaf 229)TLS 1.3:                  $(tput setaf 7)On"
echo "    $(tput setaf 229)Automatic HTTPS Rewrites: $(tput setaf 7)Off\n"
echo "$(tput setaf 6)4. $(tput setaf 7)Go to \"$(tput setaf 622)Overview$(tput setaf 7)\" and scroll down to the bottom of the page."
echo "$(tput setaf 6)5. $(tput setaf 7)Click on \"Get your API token$(tput setaf 7)\" and go to \"$(tput setaf 622)API Tokens$(tput setaf 7)\"."
echo "$(tput setaf 6)6. $(tput setaf 7)Click on \"$(tput setaf 622)View$(tput setaf 7)\" in your \"$(tput setaf 622)Global API Key$(tput setaf 7)\"."
echo "$(tput setaf 6)7. $(tput setaf 7)Paste your API below and press enter\n"

read -p "$(tput setaf 6)> $(tput setaf 7)Insert your Cloud Flare Global API Key: $(tput setaf 6)" apicf
echo -n "$(tput setaf 7)"
read -p "$(tput setaf 6)> $(tput setaf 7)Enter your Cloud Flare email: $(tput setaf 6)" emailcf
echo -n "$(tput setaf 7)"

${sudo_cmd}mkdir /root/.secrets
sudo chmod 0700 /root/.secrets/
touch /root/.secrets/cloudflare.ini

echo "dns_cloudflare_email = \"${emailcf}\"" > /root/.secrets/cloudflare.ini
echo "dns_cloudflare_api_key = \"${apicf}\"" >> /root/.secrets/cloudflare.ini

sudo chmod 0400 /root/.secrets/cloudflare.ini

fi

}
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
    cloudflareconfig
    menu
    ;;
    2|02)
    clear
    sleep 0.3
    ${sudo_cmd}wget https://raw.githubusercontent.com/Zonimi/NGINX-CONFIG/master/modules/menu.sh -O /bin/menu > /dev/null 2>&1
    ${sudo_cmd}chmod +x /bin/menu
    ${sudo_cmd}rm -r ${PATHDIR}
    clear
    cloudflareconfig
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
