FROM    mattdm/fedora-small
RUN     yum install mariadb mariadb-server git wget curl tar -y
RUN     git config --global user.name "BitcoinersWithoutBorders"
RUN     git config --global user.email "email@example.com"
RUN     git config --global credential.helper cache
RUN     git clone https://github.com/bitcoinerswithoutborders/config.git /docker/config

RUN     cp /docker/www/hhvm.repo /etc/yum.repos.d/hhvm.repo
RUN     cd /tmp
RUN     rpm --import /docker/www/hhvm.gpg.key
RUN     yum install hhvm -y

RUN     cd /docker/www/
RUN     wget https://wordpress.org/latest.tar.gz /docker/www/
RUN     tar -xzvf /docker/www/latest.tar.gz
RUN     ls -l /docker/www
RUN     mv /docker/www/wordpress/ /docker/www/bwb

RUN     curl -sS https://getcomposer.org/installer > /docker/www/composer.php	
RUN     mv /docker/www/composer.json /docker/www/bwb/
RUN     hhvm /docker/www/composer.php install

RUN     useradd bwb-hhvm
RUN     useradd bwb-mysql
