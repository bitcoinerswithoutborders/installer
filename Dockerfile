FROM    mattdm/fedora-small


RUN     yum install mariadb mariadb-server git wget curl tar -y
RUN     git config --global user.name "BitcoinersWithoutBorders"
RUN     git config --global user.email "email@example.com"
RUN     git config --global credential.helper cache
RUN     git clone https://github.com/bitcoinerswithoutborders/config.git /docker/config

RUN		chmod +x /docker/config/hhvm.sh

RUN     cp /docker/config/hhvm.repo /etc/yum.repos.d/hhvm.repo
RUN     cd /tmp
RUN     rpm --import /docker/config/hhvm.gpg.key
RUN     yum install hhvm -y

RUN     mkdir /docker/www && cd /docker/www/

RUN		mkdir /docker/composer
RUN     curl -sS https://getcomposer.org/installer > /docker/composer/composer.php	
RUN     mkdir /docker/www/bwb
RUN     mv /docker/config/composer.json /docker/www/bwb/
RUN 	cd /docker/www/bwb

RUN		chmod +x /docker/composer/composer.php

RUN     hhvm /docker/composer/composer.php install
RUN		cp //composer.phar /docker/www/

RUN     useradd bwb-hhvm
RUN     useradd bwb-mysql

RUN		cd /docker/www/bwb && hhvm /docker/www/composer.phar install
