#!/bin/bash
#Trabajo practico 2 del Bootcamp de WebExperto
#Autor: Tomas Mascia. Juan Schiavoni. Natanael Canteros

#Zona Horaria Actual
zona_actual=$(timedatectl | grep "Time zone" | awk '{print $3}')

#Zona horaria deseada
zona_deseada="America/Argentina/Buenos_Aires"

#primero compruebo si el script esta ejecutado por un usuario root ya que voy a necesitar permisos
if [ "$(id -u)" -ne 0 ]; then
        echo -e "\nEste Script debe ser ejecutado por un usuario con permisos de root"
        exit 1
else

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 1"
        echo -e "\n"

        #1
        #Compruebo si la zona horaria ya esta en Argentina
        if [ "$zona_actual" = "$zona_deseada" ]; then
                echo -e "\nLa zona horaria ya está configurada en $zona_actual"
        else
                echo -e "\nCambiando zona horaria..."
                timedatectl set-timezone "$zona_deseada"
        fi

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 2"
        echo -e "\n"

        #2
        echo -e "\nCambiando el nombre del host.."
        hostnamectl set-hostname bootcampwebexperto

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 3"
        echo -e "\n"

        #3
        #Verifico que el usuario webexperto no exista
        if cat /etc/passwd | grep -q webexperto; then
                echo -e "\nEl usuario ya existe. "
                #Compruebo si el usuario existente tiene permisos, sino se los doy
                if groups webexperto | grep -qw "sudo"; then
                        echo "Y tiene permisos de root"
                else
                        echo "Dandole permisos.."
                        usermod -aG sudo webexperto
                fi
        else
                echo -e "\nCreando user..."
                adduser --disabled-password --gecos "" webexperto

                #Asigno una contraseña para el usuario
                echo "webexperto:web123" | chpasswd
                echo -e "\nContraseña de webexperto: web123"

                echo -e "\nAgregando a sudo..."
                usermod -aG sudo webexperto
        fi

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 4"
        echo -e "\n"

        #4
        if cat /etc/passwd | grep -q sshuser; then
                echo -e "\nEl usuario ya existe. "
                #Para asegurarme que funcione la conexion ssh
                sshd_config="/etc/ssh/sshd_config"
		sed -i '/^PermitRootLogin/d; /^AllowUsers/d' "$sshd_config"
		echo -e "PermitRootLogin no\nAllowUsers sshuser" >> "$sshd_config"
                apt install -y openssh-server
                systemctl start ssh
                systemctl enable ssh
        else
                echo -e "\nCreando usuario "sshuser". "
                adduser --disabled-password -gecos "" sshuser

                #Asigno una contraseña para el usuario sshuser
                echo "sshuser:ssh123" | chpasswd
		echo -e "\nContraseña de sshuser: ssh123"

                echo -e "\nLa IP es: $(hostname -i)"
                
                sshd_config="/etc/ssh/sshd_config"
		sed -i '/^PermitRootLogin/d; /^AllowUsers/d' "$sshd_config"
		echo -e "PermitRootLogin no\nAllowUsers sshuser" >> "$sshd_config"

                #Para asegurarme que funcione la conexion via ssh       
                apt install -y openssh-server
                systemctl start ssh
                systemctl enable ssh
        fi

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 5"
        echo -e "\n"

        #5
        apt update  && apt upgrade -y

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 6 y 7"
        echo -e "\n"

        #6 y 7
        #Verifico si Docker ya está instalado
        if dpkg -l | grep -q docker-ce && dpkg -l | grep -q docker-compose-plugin; then
                echo -e "\nDocker ya está instalado."
        else
                echo -e "\nInstalando Docker..."

                #Actualizo los repositorios e instalo dependencias necesarias
                apt update
                apt install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release

                #Agrego la clave GPG oficial de Docker
                install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
		gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                chmod a+r /etc/apt/keyrings/docker.gpg

                #Agrego el repositorio de Docker
                echo \
                "deb [arch=$(dpkg --print-architecture) \
                signed-by=/etc/apt/keyrings/docker.gpg] \
                https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | \
                tee /etc/apt/sources.list.d/docker.list > /dev/null

                #Actualizo la lista de paquetes e instalo Docker
                apt update
                apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 8"
        echo -e "\n"

        #8
        #Verifico si el grupo docker existe
        if getent group docker > /dev/null; then
                #Inicio el servicio
                systemctl enable docker
                sudo systemctl start docker
                #sudo systemctl status docker
        else
                sudo groupadd docker
                systemctl enable docker
                sudo systemctl start docker
                #sudo systemctl status docker
        fi

        echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 9, 10 y 11"
        echo -e "\n"

        #9, 10 y 11
        apt install -y mc && apt install -y vim && apt install -y net-tools
	
	echo -e "\n----------------------------------------------------------------------------------------------------"
        echo -e "\nEjercicio 12"
        echo -e "\n"

        #12
        if cat /etc/passwd | grep -q nginx; then
                echo -e "\nEl usuario ya existe. "
                usermod -aG docker nginx
        else
                adduser --disabled-password --gecos "" nginx

                #Asigno una contraseña para el usuario
                echo "nginx:ngi123" | chpasswd
                echo -e "\nContraseña de nginx: ngi123"

                usermod -aG docker nginx
                newgrp docker
        fi
	
	set -x

        echo -e "\n----------------------------------------------------------------------------------------------------"
        
        # Instalar Zabbix si no está instalado
        
        if dpkg -l | grep -q zabbix-server-mysql; then
            echo "Zabbix ya está instalado."
        else
            echo "Zabbix no está instalado. Procediendo con la instalación..."

        ZABBIX_REPO="https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb"

        wget $ZABBIX_REPO -O zabbix-release.deb || { echo "Error al descargar el paquete de Zabbix"; exit 1; }
        sudo dpkg -i zabbix-release.deb || { echo "Error al instalar el paquete .deb de Zabbix"; exit 1; }
        sudo apt update || { echo "Error al actualizar los repositorios"; exit 1; }

        sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent || {
            echo "Error al instalar Zabbix"; exit 1;
        }

        echo "Zabbix se ha instalado correctamente."
        
        fi

        echo -e "\nFin del Script!"
        echo -e "\nFin del Script!"


fi


