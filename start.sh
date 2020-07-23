#!/bin/bash

sudo apt update && sudo apt -y upgrade

language (){
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "\e[1;3;31m[\e[1;3;32m+\e[1;3;31m] \e[1;3;33mSelect your language\e[0m"
printf "\n"
echo "  \e[1;3;31m[\e[1;3;36m01\e[1;3;31m] \e[1;3;33mPortuguês (Brasil)              
  \e[1;3;31m[\e[1;3;36m02\e[1;3;31m] \e[1;3;33mEnglish"
printf "\n"
read -p "$(tput setaf 6)> $(tput setaf 7)Your language: $(tput setaf 6)" language
echo -n "$(tput setaf 7)"
case "$language" in
    1|01)
    clear
    sleep 0.3
    wget https://github.com/Zonimi/NGINX-CONFIG/blob/master/modules/menu.sh -O /bin/menu > /dev/null 2>&1
    chmod +x /bin/menu
    wget https://github.com/Zonimi/NGINX-CONFIG/blob/master/modules/installweb.sh -O /bin/installweb > /dev/null 2>&1
    chmod +x /bin/installweb
    wget https://raw.githubusercontent.com/Zonimi/WebServer/master/Modulos/pt-br/instalarphp.sh -O /bin/instalarphp > /dev/null 2>&1
    chmod +x /bin/createdomain
    clear
    menu
    ;;
    2|02)
    clear
    sleep 0.3
    wget https://raw.githubusercontent.com/Zonimi/WebServer/master/Modulos/en-us/menu.sh -O /bin/menu > /dev/null 2>&1
    chmod +x /bin/menu
    wget https://raw.githubusercontent.com/Zonimi/WebServer/master/Modulos/en-us/atualizarsistema.sh -O /bin/atualizarsistema > /dev/null 2>&1
    chmod +x /bin/atualizarsistema
    wget https://raw.githubusercontent.com/Zonimi/WebServer/master/Modulos/en-us/instalarphp.sh -O /bin/instalarphp > /dev/null 2>&1
    chmod +x /bin/instalarphp
    clear
    menu
    ;;
    *)
    echo "\n\033[1;31mInvalid option!\033[0m"
    sleep 3
    clear
    sleep 0.3
    language
esac
}
language
