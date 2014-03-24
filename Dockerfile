#  ANNUIT COEPTIS HUMANAE LIBERTAS  #
#BWWWWWWWWWB   BWWWB   BWWWWWWWWWWWB#   License: Copyleft
#BWWWWWWWWWB   BWWWB   BWWWWWWWWWWWB#            All Rites Reversed - Ⓐ
#BWWWWWWWWWB   BWWWB     BWWWWWWWWWB#
#BWB                        BWWWWWWB#   Url: http://install.bwb.is/
#BWB        BWWWWWWWWWB        BWWWB#   Contributors:
#BWB        BWWWWWWWWWWB         BWB#     Jascha Ehrenreich
#BWB        BWWWWWWWWWB          BWB#     jascha@jaeh.at
#BWB                             BWB#   
#BWB        BWWWWWWWWWB         BWWB#
#BWB        BWWWWWWWWWWB        BWWB#
#BWB        BWWWWWWWWWB        BWWWB#
#BWB                          BWWWWB#
#BWB                         BWWWWWB#
#BWB                          BWWWWB#
#BWB        BWWWB BWWWB        BWWWB#
#BWB        BWWWB BWWWB         BWWB#
#BWB        BWWWB BWWWB          BWB#
#BWB        BWWWB BWWWB          BWB#
#BWB        BWWWB BWWWB          BWB#
#BWB        BWWWB BWWWB         BWWB#   This dockerfile will install
#BWB         BWB   BWB          BWWB#   the bwb development env
#BWB                         BWWWWWB#   into a docker-vm and start it
#BWWWWWWWWWB  BWWWWB   BWWWWWWWWWWWB#
#BWWWWWWWWWB  BWWWWB   BWWWWWWWWWWWB#
#BWWWWWWWWWB  BWWWWB   BWWWWWWWWWWWB#   Not in use yet. very crude.
#      KEEP CALM - BITCOIN ON       #



########################################################################
#
# This is the central dockerfile used to set up the environment
# that we use to run all our wordpress installs in.
# to build it first install http://docker.io and git.
# then you can simply clone this repository:
# git clone https://github.com/bitcoinerswithoutborders/installer
# cd installer
#
# now that you are in the new directory just run:
# docker build .
#
# the installer will then download the git repo with the config files
# to the vm, install mariadb(mysql), hhvm, git and wget.
# all of this files will be loaded into the /docker directory.
#
# to customize any settings just edit the scripts below,
# work on a web based config creator will start soon.



########################################################################
#
# use the minimal fedora package from mattdm's repo as a starting point.

FROM mattdm/fedora-small



########################################################################
#
# install mysql, git, wget

# individual steps for the packages to allow individual caching
RUN yum install mariadb mariadb-server -y
RUN yum install git -y
RUN yum install wget -y
RUN yum install makepasswd -y

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
#
# Use the hhvm repo and gpg from the config github repo loaded above
# and install hhvm using it.
# After this hhvm is available as hhvm from the shell
# to execute php files directly.
# hhvmd (/usr/bin/hhvmd) starts, restarts and stops the hhvm as a daemon


# copy the hhvm.repo file into yum.repos.d
# this makes it accessible through the yum package manager 
RUN cp /docker/config/hhvm.repo /etc/yum.repos.d/hhvm.repo

# import the key downloaded through the github repo
# key management for repos needs more work.
RUN rpm --import /docker/config/hhvm.gpg.key

# install hhvm using yum
RUN yum install hhvm -y

# make hhvm.sh executable
RUN chmod +x /docker/config/hhvm.sh

# copy hhvm.sh onto the PATH and rename it to hhvmd
RUN ln -s /docker/config/hhvm.sh /bin/hhvmd



########################################################################
#
# Install getcomposer.org

# create the data directory and change to it
RUN mkdir /docker/www && cd /docker/www/

# create the composer dir that will house the composer executable
RUN mkdir /docker/composer

# install the newest composer version into the path
RUN curl -sS https://getcomposer.org/installer \
    > /docker/composer/composer.php 

# create the actual webroot dir
RUN mkdir /docker/www/bwb && cd /docker/www/bwb

# copy the composer settings from the config dir
RUN mv /docker/config/composer.json /docker/www/bwb/

# make composer executable
RUN chmod +x /docker/composer/composer.php


########################################################################
#
# run through the composer.phar install 

# downloads the .phar file
RUN hhvm /docker/composer/composer.php install

# copy the composer.phar somehwere the user can access it for whatever.
RUN mv //composer.phar /docker/composer/composer.phar

# create composer symlink
RUN ln -s /docker/composer/composer.phar /bin/composer


########################################################################
#
# Add needed user for hhvm, mysql (later postfix, fpdf etc?)
# Passwordgen needs to be done, names need to be randomized.


# create all needed users
RUN /docker/config/createusers.sh bwb-hhvm
RUN /docker/config/createusers.sh bwb-mariadb

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# MISSING HERE:

# MYSQL SETUP:
#   create database,
#   user permissions for mariadb user added above

# SSH:
#   PUB/PRIV KEY SETUP, Disallow root access,

# EMAIL SERVER SETUP

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

########################################################################
#
# Install wordpress, wp-cli, plugins and themes using composer.json
# from the config repo loaded above

# to edit the installed packages fork the config repo, change the 
# composer.json file and rewrite this file to link to your fork.
# there will be a simple web installer later.

#RUN cd /docker/www/bwb && hhvm /docker/composer/composer.phar install



########################################################################
#
# Restart hhvmd with newest source
# (it shouldnt be running, restarting it wont hurt, just to make sure.

# Create hhvm log folder
RUN mkdir /docker/log

# restart hhvmd
RUN hhvmd restart

########################################################################
#
# Install and Setup ssh
RUN yum install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd

# open bash here and leave it open?
# enable the ports of the docker instance to be routed through
# the parent machine and accessible from a browser locally.
# leave all outwards routing to the parent os.
