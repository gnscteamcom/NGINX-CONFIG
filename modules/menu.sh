#!/bin/bash

addhost () {
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

# Question which domain
read -p "$(tput setaf 6)> $(tput setaf 7)Enter domain: $(tput setaf 6)" domain
echo -n "$(tput setaf 7)"
echo "\n$(tput setaf 6)! $(tput setaf 8)Answer \"yes\" or \"no\"."
read -p "$(tput setaf 6)> $(tput setaf 7)Are you using CloudFlare: $(tput setaf 6)" ssl_install
echo -n "$(tput setaf 7)"

# Create website
cp /etc/nginx/sites-available/exemple.com.conf /etc/nginx/sites-available/${domain}.conf
sudo sed -i "s/exemple.com/${domain}/g" /etc/nginx/sites-available/${domain}.conf
mkdir -p /var/www/${domain}/public
chown www-data /var/www/${domain}/public

# Comment out SSL related directives in the configuration
sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/sites-available/${domain}.conf
sed -i 's/80/81/g; s/443/80/g' /etc/nginx/sites-available/${domain}.conf
sudo nginx -t && sudo systemctl reload nginx

# Obtain SSL certificates from Let's Encrypt using Certbot:
if [ "${ssl_install}" = "y" -o "${ssl_install}" = "Y" -o "${ssl_install}" = "yes" -o "${ssl_install}" = "YES" ]; then
sudo certbot certonly --dns-cloudflare --email info@${Domain} --force-renewal -n --agree-tos --dns-cloudflare-credentials /root/.secrets/cloudflare.ini -d ${domain},*.${domain} --preferred-challenges dns-01
else
certbot certonly --webroot -d ${domain} --email info@${domain} -w /var/www/_letsencrypt -n --agree-tos --force-renewal
fi

Uncomment SSL related directives in the configuration:
sed -i -r 's/#?;#//g' /etc/nginx/sites-available/${domain}.conf
sed -i 's/80/443/g; s/81/80/g' /etc/nginx/sites-available/${domain}.conf

# Configure Certbot to reload NGINX when it successfully renews certificates:
echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh

# Add symbolic link
ln -s /etc/nginx/sites-available/${domain}.conf /etc/nginx/sites-enabled/${domain}

# Reload NGINX to load in your new configuration:
sudo nginx -t && sudo systemctl reload nginx

echo "$(tput setaf 6)! $(tput setaf 7)Select an option (number): $(tput setaf 6)"

}

removehost () {

# Question which domain
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "\e[1;3;31m[\e[1;3;32m-\e[1;3;31m] \e[1;3;33mWhich host do you want to remove?\e[0m"
printf "\n"
ls -1 /etc/nginx/sites-enabled/
printf "\n"
echo "$(tput setaf 6)! $(tput setaf 8)Send \"leave\" to return."
read -p "$(tput setaf 6)> $(tput setaf 7)Specify the domain: $(tput setaf 6)" removedomain
echo -n "$(tput setaf 7)"

# Remove files nginx
rm /etc/nginx/sites-available/${removedomain}.conf > /dev/null 2>&1
unlink /etc/nginx/sites-enabled/${removedomain}

# Remove cert SSL
certbot delete --cert-name ${removedomain} > /dev/null 2>&1

# Reload NGINX
sudo systemctl reload nginx > /dev/null 2>&1

case "$removedomain" in
    Leave|leave|LEAVE|\n)
    echo "\n\033[1;31mReturning...\033[0m"
    sleep 2
    menu
    ;;
esac
}

googledriveadvanced () {

echo "work"
sleep 5
menu
}
menu_script () {
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo -ne "\e[1;3;31m[\e[1;3;32m×\e[1;3;31m] \e[1;3;33mINSTALL SCRIPT's\e[0m"
printf "\n\n"
echo -ne "    \e[1;3;31m[\e[1;3;36m01\e[1;3;31m] \e[1;3;33mGoogle Drive Advanced Player (with cPanel)"             
#    \e[1;3;31m[\e[1;3;36m02\e[1;3;31m] \e[1;3;33mRemove host"
printf "\n\n"
echo "$(tput setaf 6)! $(tput setaf 8)Send \"leave\" to return."
read -p "$(tput setaf 6)> $(tput setaf 7)Select an option (number): $(tput setaf 6)" optionmenu
echo -n "$(tput setaf 7)"
case "$optionmenu" in
    1|01)
    clear
    sleep 0.3
    googledriveadvanced
    menu
    ;;
#    2|02)
#    clear
#    sleep 0.3
#    removehost
#    menu
#    ;;
    Leave|leave|LEAVE)
    clear
    sleep 0.1
    printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    ;;
    *)
    printf "  \033[1;31mInvalid!\033[0m"
    sleep 1
    clear
    sleep 0.3
    menu
esac
}

menu (){
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo -ne "\e[1;3;31m[\e[1;3;32m×\e[1;3;31m] \e[1;3;33mMAIN MENU\e[0m"
printf "\n\n"
echo -ne "    \e[1;3;31m[\e[1;3;36m01\e[1;3;31m] \e[1;3;33mAdd host (Domain)    \e[1;3;31m[\e[1;3;36m03\e[1;3;31m] \e[1;3;33mInstall script's 
    \e[1;3;31m[\e[1;3;36m02\e[1;3;31m] \e[1;3;33mRemove host"
printf "\n\n"
echo "$(tput setaf 6)! $(tput setaf 8)Send \"leave\" to return."
read -p "$(tput setaf 6)> $(tput setaf 7)Select an option (number): $(tput setaf 6)" optionmenu
echo -n "$(tput setaf 7)"
case "$optionmenu" in
    1|01)
    clear
    sleep 0.3
    addhost
    menu
    ;;
    2|02)
    clear
    sleep 0.3
    removehost
    menu
    ;;
    3|03)
    clear
    sleep 0.3
    menu_script
    menu
    ;;
    Leave|leave|LEAVE)
    clear
    sleep 0.1
    printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    ;;
    *)
    printf "  \033[1;31mInvalid!\033[0m"
    sleep 1
    clear
    sleep 0.3
    menu
esac
}
menu
