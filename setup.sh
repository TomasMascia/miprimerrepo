# ! bin / bash
# Autor: Tomas Mascia, Juan Schiavoni ,Natanael Cantero

    # Primero validamos que el usuario sea root, en caso contrario lo sacamos

    if [ "$EUID" -ne 0 ]; then
        echo "Este script debe ejecutarse como root."
        exit 1
    else

        # Ahora voy a ir haciendo todas las consignas una por una


        #--------------------------------------------------------------------------------------------------------------------------------------
        # Actualizar zona horaria de Argentina:
        # Valido si la zona ya es esa, sino la cambio

        ZONE="America/Argentina/Buenos_Aires"
        CURRENT_ZONE=$(readlink -f /etc/localtime | sed 's|/usr/share/zoneinfo/||')

        if [ "$CURRENT_ZONE" == "$ZONE" ]; then

            echo "La zona horaria ya está configurada como $ZONE. No se requiere ningún cambio."

        else

            echo "Cambiando la zona a $ZONE"

            ln -sf "/usr/share/zoneinfo/$ZONE" /etc/localtime

            # Muestro mensaje confirmando que se cambio la zona horaria en caso de no haber sido la misma que tenia        

            echo "Zona horaria cambiada a $ZONE"
            date
        fi

        #--------------------------------------------------------------------------------------------------------------------------------------
        # Valida las dependencias y las actualiza
        # Valido si el sistema se encuentra actualizado o no 

        if apt list --upgradable 2>/dev/null | grep -v "Listing..." | grep -q .; then

            echo "Actualizando dependencias"

            apt update -y && apt upgrade -y

        else

            echo -e "El sistema se encuentra actualizado en su totalidad\n"

        fi


        #--------------------------------------------------------------------------------------------------------------------------------------

        # Creamos un usuario sudo llamado webexperto 
        # Valido si existe el usuario llamado asi, si existe le doy los permisos, sino lo creo con los permisos

        if  grep -q "webexperto:" /etc/passwd; then

            echo -e "\nEl usuario ya existe."

            if  getent group sudo | grep -qw "webexperto"; then

                echo "webexperto:super1" | chpasswd

                echo "Tambien tiene permisos de root"

            else

                echo "El usuario no tiene permisos le damos"


                echo "webexperto:super1" | chpasswd

                usermod -aG sudo webexperto
            fi

        else

            # En el caso de que no este el usuario creado, lo creamos

            echo -e "\nEstamos creando tu usuario con permisos de root"

            adduser --disabled-password --gecos "" webexperto

            # Le coloco contraseña al usuario webexperto

            echo "webexperto:super1" | chpasswd
            echo -e "\nLa contraseña de webexperto es super1"

            # Ademas le agregamos permisos de sudo

            usermod -aG sudo webexperto
            echo -e "EL usuario de webexperto tiene permisos de root\n"

        fi

        #--------------------------------------------------------------------------------------------------------------------------------------
        
        # Valida si esta instalado Docker y en caso de no estar, lo instala
        # Validamos si esta instalado
        if command -v docker &> /dev/null; then

            echo "Docker esta instalado en su maquina"

        else

            #En el caso de no estar isntalado lo instalamos

            echo -e "Docker no esta instalado en su maquina\n"
            echo -e "Vamos a instalar docker..."

            curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
            echo -e "Docker ya se instalo en su totalidad"

        fi

        #--------------------------------------------------------------------------------------------------------------------------------------
        
        # Valida si esta instalado Docker-compose y en caso de no estar lo instala
        # Validamos si esta instalado

        if command -v docker-compose &> /dev/null; then

            echo "Docker Compose no esta en su maquina"

        else

            #En el caso de noestar instalado, lo instalamos

            echo -e "Docker Compose no esta en su  maquina\n"
            echo -e "Vamos a instalar Docker-Compose...\n"

            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

            # Ademas le damos permisos
            sudo chmod +x /usr/local/bin/docker-compose

        fi
        
        #--------------------------------------------------------------------------------------------------------------------------------------

        # Crea grupo docker e inicia el servicio
        # Verifico si el grupo existe, si no es asi lo creamos e iniciamos el servicio

        if ! getent group docker &> /dev/null; then

            echo -e "El grupo 'docker' no existe"
            echo -e "Creando el grupo 'docker'...\n"

            sudo groupadd docker

        else

            echo "El grupo 'docker' ya existe"

        fi

        # Ahora lo que hacemos es meter el usuario al grupo 'docker'

        sudo usermod -aG docker $USER

        echo "El usuario $USER ha sido añadido al grupo docker"

        # Verificamos que el servicio docker este activado, en caso contrario lo activamos

        if ! systemctl is-active --quiet docker; then

            echo -e "El servicio de docker no esta activado\n"
            echo -e "Activando el servicio de docker\n"

            sudo systemctl start docker
            sudo systemctl enable docker

            echo "Servicio activado"

        else

            echo "El servicio de docker ya esta activado"

        fi

        #--------------------------------------------------------------------------------------------------------------------------------------
        # Instalamos VIM

        if ! command -v vim &> /dev/null; then

            echo -e "VIM no esta instalado\n"
            echo -e "Vamos a instalarlo\n"

            sudo apt install -y vim

            echo -e "El VIM ya se instalo correctamente"

        else

            # En caso de estar instalado, mostramos un mensaje que lo indique

            echo -e "El VIM esta instalado :D"

        fi

        #--------------------------------------------------------------------------------------------------------------------------------------
        # Instalamos NET-TOOLS

        if ! command -v ifconfig &> /dev/null; then

            echo -e "NET-TOOLS no esta instalado\n"
            echo -e "Vamos a instalarlo\n"

            sudo apt install -y net-tools

            echo -e "El NET-TOOLS ya se instalo correctamente"

        else

            # En caso de estar instalado, mostramos un mensaje que lo indique

            echo -e "El NET-TOOLS esta instalado :D"
        #--------------------------------------------------------------------------------------------------------------------------------------

        # Crear un usuario Nginx y dar permisos de docker
        # Verificar si el usuario nginx ya existe

        if id "nginx" &> /dev/null; then
            echo "nginx:super2" | chpasswd
            echo -e "El usuario nginx ya existe\n"

        else

            echo -e "Vamos a crear el usuario nginx\n"

            sudo adduser --disabled-password --gecos "" nginx
            echo "nginx:super2" | chpasswd
            echo -e "EL usuario nginx se ha creado corerctamente\n"

        fi

        # Valida si se encuentra en el grupo de docker, en caso de no estar, lo agrega

        if id -nG nginx | grep -qw docker; then

            echo -e "El usuario nginx se encuentra en el grupo de 'docker'\n"

        else

            # En caso de no estar lo agrego al grupo 'docker'

            echo -e "Agregando al usuario al grupo 'docker'\n"

            sudo usermod -aG docker nginx

            echo -e "El usuario nginx tiene ya los permisos para 'docker'\n"

        fi


        fi

        #--------------------------------------------------------------------------------------------------------------------------------------
