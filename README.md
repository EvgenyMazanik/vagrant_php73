# vagrant
The Big Hot Vagrant Machine

## Stack

* Apache2
* Apache2 Modules
    * headers
    * rewrite
    * ssl
* Composer
* Git
* MySQL
* PHP-7.3 in Development mode
    * php7.3-curl
    * php7.3-gd
    * php7.3-mbstring
    * php7.3-mysql
    * php7.3-xml
    * php7.3-zip
    * php7-dev
* PHPUnit-7.2



* phpMyAdmin
* PHPUnit

## Install

Make directory "~/.EvgenyMazanik-vagrant" .
Change directories for "/host" and "/config" directories for config.vm.synced_folder param.
Add all hosts to the host file:
    192.168.111.73 phpmyadmin
    192.168.111.73 test.local
