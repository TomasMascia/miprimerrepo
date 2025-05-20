# ! bin / bash
# Autor: Tomas Mascia, Juan Schiavoni ,Natanael Cantero

# Descargamos el repo en .zip desde mi GitHub para poder ejecutar mi docker-compose

    wget -P /home/nginx https://github.com/Nataa19/my-app/archive/refs/heads/main.zip

    cd /home/nginx && unzip main.zip

    rm -rf main.zip

    cd my-app-main && rm -rf README.md README.pdf setup.sh init.sh

    cd /home/nginx

    chown -R nginx:nginx /home/nginx/my-app-main

# Descargamos el cliente DUC para NO-IP para poder ejecutar el contenedor con la DNS

    wget -P /home/nginx --content-disposition https://www.noip.com/download/linux/latest

    tar xf noip-duc_3.3.0.tar.gz

    rm -rf noip-duc_3.3.0.tar.gz

    chown -R nginx:nginx noip-duc_3.3.0

    cd noip-duc_3.3.0/binaries && sudo apt install ./noip-duc_3.3.0_amd64.deb

    echo noip-duc -g all.ddnskey.com --username pzvfdr6 --password wcd8dNYoLeqD > /home/nginx/initduc.txt 

    cd /home/nginx

    chown nginx:nginx initduc.txt

    cd

