#        -        ANNUIT COEPTIS  -  HUMANAE LIBERTAS         -        #
#MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMM~ .MM+=MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMM. .M?..MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMM. .M=..MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMM      ...... .=MMMMMMMMMMMMMMMMMMMMMM+..MM. MMMMMMMMMMMMMMM#
#MMMMMMMMMM.   ..,,..      .+MMMMMMMMMMMMMMMMMMMM= .MM  MMMMMMMMMMMMMMM#
#MMMMMMMMM?.   :MMMM=   .MMMMMMMMMMMMMMMMMMM... .  .~M .MMMMMMMMMMMMMMM#
#MMMMMMMMMM.   ~MMMM,   ,MMMMMMMMMMMMMMMMMMM.  .   ........+MMMMMMMMMMM#
#MMMMMMMMMMM.  .,=,M.   =MMMMMMMMMMMMMMMMMMMMMM~  .,?+..   .=MMMMMMMMMM#
#MMMMMMM+... ..... ..   ..,,=+MIMMMMMMMMMMMMMMM   .~MMMM..   +MMMMMMMMM#
#MMMMMMM    .:MMMMMM.  ..    . ........=:+MMMM?   .+MMMM,. . +MMMMMMMMM#
#MMMMMMM    ,MMMMMMM.  .M:   .~~     ..+ . ....   .:==~:  ..~MMMMMMMMMM#
#MMMMMMM..  .MMMMMMM.  .M=   .IMM    MMMM,  ...   ...  .  .:MMMMMMMMMMM#
#MMMMMMM=. . ...=+~+   .MM    7MM,   MMMM. .MI.   =MMI+:    .MMMMMMMMMM#
#MMMMMMMMM?,... ...    ,MM..  ?MM=   MMM,. .M+.  .MMMMMM:.   :MMMMMMMMM#
#MMMMMMMMMMMMM= ,,,. ..=MM,. .:MM.   =MM  .~M~.  .MMMMMM:.   :MMMMMMMMM#
#MMMMMMMMMMMMM, +MM..MMMMM~. .~M..   ,MI  :MM:   ..,++:.    .+MMMMMMMMM#
#MMMMMMMMMMMMM .MM=.~MMMMM=. .,M..   .M...MMM.  .... .  ....MMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMM. ..~.~.. ., .+MMMMM .IM: ,::=+MMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMM. .. .M+. .. =MMMMM+.,MM. MMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMM:   .MM~.   .MMMMMM+~~MM..MMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMM~   .MMM.   .MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMMM==:=MMM... +MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#
#           -          KEEP CALM  -  BITCOIN ON!           -           #

# License: Copyleft - All Rites Reversed - BitcoinersWithoutBorders - Ⓐ
#
# Contributors: [
#   {
#		name: Jascha Ehrenreich, 
#		email: jascha@jaeh.at, 
#		url: http://jaeh.at, 
#		github: https://github.com/jaeh
#	}
# ]

########################################################################
#
# This is the central dockerfile used to set up the environment
# that we use to run all our wordpress installs in.


########################################################################
# use the minimal fedora package from mattdm's repo as a starting point.
FROM mattdm/fedora-small


########################################################################
# install mysql, git, wget, curl, tar
RUN yum install mariadb mariadb-server git wget curl tar -y

########################################################################
# Configure git to use the correct email and username for you

RUN git config --global user.name "username" && \
	git config --global user.email "email@example.com" && \
	git config --global credential.helper cache

########################################################################
# Download the bwb config repo to the /docker/config dir
# This repo includes the composer.json and the hhvm config files.

#create root docker dir
RUN mkdir /docker

# clone the config repo into /docker/config
RUN git clone https://github.com/bitcoinerswithoutborders/config.git \
	/docker/config


########################################################################
# Use the hhvm repo and gpg from the config github repo loaded above
# and install hhvm using it.
# After this hhvm is available as hhvm from the shell
# to execute php files directly.
# hhvmd (/usr/bin/hhvmd) starts, restarts and stops the hhvm daemon.

# make hhvm.sh executable
RUN chmod +x /docker/config/hhvm.sh

# copy hhvm.sh onto the PATH and rename it to hhvmd
RUN	cp /docker/config/hhvm.sh /usr/bin/hhvmd

# copy the hhvm.repo file into yum.repos.d
# this makes it accessible through the yum package manager 
RUN cp /docker/config/hhvm.repo /etc/yum.repos.d/hhvm.repo

# import the key downloaded through the github repo
# key management for repos needs more work.
RUN rpm --import /docker/config/hhvm.gpg.key


# install hhvm using yum
RUN yum install hhvm -y


########################################################################
#
# Install composer


# create the needed directory and change to it
RUN     mkdir /docker/www && cd /docker/www/

# create the composer dir that will house the composer executable
RUN	mkdir /docker/composer

# install the newest composer version into the path
RUN curl -sS https://getcomposer.org/installer \
	> /docker/composer/composer.php	

# make composer executable
RUN	chmod +x /usr/bin/composer

RUN     mkdir /docker/www/bwb
RUN     mv /docker/config/composer.json /docker/www/bwb/
RUN 	cd /docker/www/bwb
RUN		chmod +x /docker/composer/composer.php


########################################################################
#
# run through the composer.phar install 

RUN hhvm /docker/composer/composer.php install

# copy composer.phar as composer onto the path
RUN	cp //composer.phar /usr/bin/composer

# copy the composer.phar somehwere the user can access it.
RUN	mv //composer.phar /docker/composer/composer.phar


########################################################################
#
# Add needed user for hhvm, mysql (later postfix, fpdf etc?)
# Passwordgen needs to be done, names need to be randomized.

RUN     useradd bwb-hhvm
RUN     useradd bwb-mysql


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# MISSING HERE:
# USER PASSWD, MYSQL SETUP, ROOT RENAME, SSH PUB/PRIV KEY SETUP, ETC


########################################################################
#
# Install wordpress, wp-cli, plugins and themes using composer.json
# from the config repo loaded above

#RUN cd /docker/www/bwb && hhvm /docker/www/composer.phar install


########################################################################
#
# Restart hhvmd with newest source if it is running
# (it shouldnt, it wont hurt to make sure.

RUN hhvmd restart

