#!/bin/bash

addhost () {
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

# Question which domain
read -p "$(tput setaf 6)> $(tput setaf 7)Enter the domain: $(tput setaf 6)" domain
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
sudo certbot certonly --dns-cloudflare --email info@${domain} --force-renewal -n --agree-tos --dns-cloudflare-credentials /root/.secrets/cloudflare.ini -d ${domain},*.${domain} --preferred-challenges dns-01
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

# Install
sudo apt -y install unzip nodejs npm
npm install pm2 -g
ufw allow 6666
ufw allow 6868

read -p "$(tput setaf 6)> $(tput setaf 7)Enter the domain: $(tput setaf 6)" domain_gdap
echo -n "$(tput setaf 7)"
read -p "$(tput setaf 6)> $(tput setaf 7)Enter the subdomain: $(tput setaf 6)" subdomain_gdap
echo -n "$(tput setaf 7)"
read -p "$(tput setaf 6)> $(tput setaf 7)Enter the prefix: $(tput setaf 6)" prefix_gdap
echo -n "$(tput setaf 7)"
read -p "$(tput setaf 6)> $(tput setaf 7)Number of servers: $(tput setaf 6)" n
echo -n "$(tput setaf 7)"

# Obtain path dir
${sudo_cmd}echo "${PWD}" > pathdir
PATHDIR=$(cat pathdir)
${sudo_cmd}rm pathdir
echo "${PATHDIR}"

# Add host panel
cp /etc/nginx/sites-available/exemple.com.conf /etc/nginx/sites-available/${domain_gdap}.conf
sudo sed -i "s/exemple.com/${domain_gdap}/g" /etc/nginx/sites-available/${domain_gdap}.conf
mkdir -p /var/www/${domain_gdap}/public
chown www-data /var/www/${domain_gdap}/public

# copy files
cp ${PATHDIR}/modules/setup/GDAP/* /root/

# Unzip files and delete
cd /root/
unzip LoadBalancer.zip
unzip ProxyStream.zip
rm LoadBalancer.zip
rm ProxyStream.zip
mv /root/panel.zip /var/www/${domain_gdap}/public
cd /var/www/${domain_gdap}/public
unzip panel.zip
rm panel.zip

# Start node
cd /root/LoadBalancer/bin
pm2 start www -i 0 --name LoadBalancer
cd /root/ProxyStream/bin
pm2 start www -i 0 --name ProxyStream

# Edit files
keyencrypt="$(tr -dc 'A-Za-z0-9!%&()*+-./@[\]_{}' </dev/urandom | head -c 20 ; echo)"
sudo sed -i "s/https:\/\/proxy.apicodes.ml/https:\/\/proxy.${domain_gdap}/g" /var/www/${domain_gdap}/public/config.php
sudo sed -i "s/yourkeyhere/${keyencrypt}/g" /root/LoadBalancer/models/CacheManager.js
sudo sed -i "s/yourkeyhere/${keyencrypt}/g" /root/ProxyStream/models/CacheManager.js
sudo sed -i "s/'yourdomain.com'/'${domain_gdap}'/g" /root/LoadBalancer/configs/servers.js
sudo sed -i "s/'sv'/'${prefix_gdap}'/g" /root/LoadBalancer/configs/servers.js
sudo sed -i 's/"yourdomain.com","www.jwplayer.com"//g' /root/ProxyStream/configs/servers.js

# Create host
touch /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf
{
echo "upstream LoadBalancer {"
echo "    server 127.0.0.1:6666;"
echo "}"
echo "upstream ProxyStream {"
echo "    server 127.0.0.1:6868;"
echo "}"
echo ""
echo "server {"
echo "    listen 443 ssl http2;"
echo "    listen [::]:443 ssl http2;"
echo "    server_name proxy.${domain_gdap};"
echo ""
echo "    # security"
echo "    include                 nginxconfig/security.conf;"
echo ""
echo "    #SSL
echo "    ssl_certificate         /etc/letsencrypt/live/${domain_gdap}/fullchain.pem;"
echo "    ssl_certificate_key     /etc/letsencrypt/live/${domain_gdap}/privkey.pem;"
echo "    ssl_trusted_certificate /etc/letsencrypt/live/${domain_gdap}/chain.pem;"
echo ""
echo "    location / {"
echo "        proxy_pass          http://LoadBalancer;"
echo "        include             nginxconfig/proxy.conf;"
echo "    }"
echo "}"
echo ""
} > /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf

for ((i=1;i<$n+1;i++));                                              
do
    {
    echo "server {"
    echo "    listen 443 ssl http2;"
    echo "    listen [::]:443 ssl http2"
    echo "    server_name ${prefix_gdpa}$i.${subdomain_gdap}.${domain_gdap};"
    echo ""
    echo "    # security"
    echo "    include                 nginxconfig/security.conf;"
    echo ""
    echo "    #SSL
    echo "    ssl_certificate         /etc/letsencrypt/live/${domain_gdap}/fullchain.pem;"
    echo "    ssl_certificate_key     /etc/letsencrypt/live/${domain_gdap}/privkey.pem;"
    echo "    ssl_trusted_certificate /etc/letsencrypt/live/${domain_gdap}/chain.pem;"
    echo ""
    echo "    location / {"
    echo "        proxy_pass          http://ProxyStream;"
    echo "        include             nginxconfig/proxy.conf;"
    echo "    }"
    echo "}"
    echo ""
    } >> /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf
done

sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf
sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/sites-available/${domain_gdap}.conf
sed -i 's/443/80/g' /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf
sed -i 's/80/81/g' /etc/nginx/sites-available/${domain_gdap}.conf
sed -i 's/443/80/g' /etc/nginx/sites-available/${domain_gdap}.conf
sudo systemctl reload nginx

echo "$(tput civis)"
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "$(tput setaf 6)+ $(tput setaf 7)Go to Cloud Flare and point the domains below to your IP;\n."
echo -n "$(tput setaf 7)"
echo "$(tput setaf 343) ${domain_gdap}"
echo "$(tput setaf 343) proxy.${domain_gdap}"
echo "$(tput setaf 343)  ${subdomain_gdap}.${domain_gdap}"
for ((i=1;i<$n+1;i++));                                              
do
    echo "$(tput setaf 343)  ${prefix_gdpa}$i.${subdomain_gdap}.${domain_gdap}"
done

echo "\n  $(tput setaf 237)ATTENTION: $(tput setaf 7)press enter only after adding the subdomains in the Cloud Flare."
sleep 5
read -p "$(tput setaf 6)> $(tput setaf 7)Press enter to continue" null
echo -n "$(tput setaf 7)"

printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "$(tput setaf 6)! $(tput setaf 7)For security, wait 60 seconds for the DNS to propagate..."

sleep 60
echo "$(tput cnorm)"

# Install cert
sudo certbot certonly --dns-cloudflare --email info@${domain_gdap} --force-renewal -n --agree-tos --dns-cloudflare-credentials /root/.secrets/cloudflare.ini -d ${domain_gdap},*.${domain_gdap} --preferred-challenges dns-01

sed -i -r 's/#?;#//g' /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf
sed -i -r 's/#?;#//g' /etc/nginx/sites-available/${domain_gdap}.conf
sed -i 's/80/443/g' /etc/nginx/sites-available/GoogleDriveAdvancedPlayer.conf
sed -i 's/80/443/g; s/81/80/g' /etc/nginx/sites-available/${domain_gdap}.conf

# Add symbolic link
ln -s /etc/nginx/sites-available/${domain}.conf /etc/nginx/sites-enabled/${domain}

# Reload NGINX to load in your new configuration:
sudo nginx -t && sudo systemctl reload nginx
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
