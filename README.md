####Dockerfile

This is the first version of the [bitcoinerswithoutborders](http://bwb.is) [docker](http://docker.io)file. 

It will be used to load all the dependencies for our toolchain into a docker container.

Have a look at the [Dockerfile](https://github.com/bitcoinerswithoutborders/installer/blob/master/Dockerfile) to get detailed informations and see the commands at the same time ;)

##### What this will do:

install a minimal fedora distro (around 150mb)

install mariadb, mariadb-server, git, wget, makepasswd, hhvm

set up git

download the bwb config from the [github repo](https://github.com/bitcoinerswithoutborders/config),

create a few users for hhvm, mariadb

give those users passwords,

symlink a bit

install [composer](http://getcomposer.org)

install and preconfigure wordpress, download wordpress plugins and themes, download wp-cli

use wp-cli to activate the plugins/themes and add the default content to our wordpress install.



#####Whats working now:

about half of the pipeline above.


