FROM    mattdm/fedora-small
RUN     yum install mariadb mariadb-server git wget -y
RUN     git config --global user.name "BitcoinersWithoutBorders"
RUN     git config --global user.email "email@example.com"
RUN     git config --global credential.helper cache
RUN     git clone https://github.com/bitcoinerswithoutborders/hhvm-config.git /var/www
RUN 	echo [hhvm] | tee -a /etc/yum.repos.d/hhvm.repo
RUN 	echo name=HHVM for Fedora 20 - x86_64 | tee -a /etc/yum.repos.d/hhvm.repo
RUN 	echo baseurl=http://dl.hhvm.com/fedora/20/x86_64/ | tee -a /etc/yum.repos.d/hhvm.repo
RUN 	cd /tmp
RUN 	wget http://dl.hhvm.com/conf/hhvm.gpg.key
RUN 	rpm --import hhvm.gpg.key
RUN 	yum install hhvm -y
RUN     git clone https://github.com/bitcoinerswithoutborders/wp.bwb.is.git /var/www/bwb/
