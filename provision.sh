#!/usr/bin/env bash

PHP_VERSION=7.3
PHPUNIT_VERSION=7.2
PHPMYADMIN_VERSION=4.8.4
MYSQL_ROOT_PASSWORD="root"

INSTALLED="= Installed ="

sudo apt-get dist-upgrade

Update () {
    echo "-- Update packages --"
    yes | sudo apt-get update
    yes | sudo apt-get upgrade
}
Update


echo ""
echo ""
echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
Update


echo ""
echo ""
echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes git
Update
INSTALLED+=" $(git --version)"


echo ""
echo ""
echo "-- Install Apache2 packages --"
sudo apt-get install apache2 -y
Update
INSTALLED+=" $(apache2 -v)"


echo ""
echo ""
echo "-- Install Apache Modules --"
sudo a2enmod headers rewrite ssl
Update


echo ""
echo ""
echo "-- Create SSL certificate --"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -config /vagrant/config/apache2_ssl.cnf
# for for add permission
sudo chown root:ssl-cert /etc/ssl/private/apache-selfsigned.key
Update

# echo ""
# echo ""
# echo "-- Generate Kyes for Apache --"
# sudo mkdir /etc/apache2/ssl
# # sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
# sudo chmod 600 /etc/apache2/ssl/*




echo ""
echo ""
echo "-- Install PHP ${PHP_VERSION} packages --"
sudo apt-get install -y language-pack-en-base
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo apt-get install python-software-properties
Update


yes | sudo apt-add-repository ppa:ondrej/php
yes | sudo apt-add-repository ppa:ondrej/apache2
Update


sudo apt-get install -y --force-yes php${PHP_VERSION} php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-zip 
sudo apt-get install -y --force-yes libapache2-mod-php${PHP_VERSION}
Update


echo ""
echo ""
echo "-- PEAR --"
sudo apt-get install -y --force-yes php-pear
pear config-set php_ini /etc/php/${PHP_VERSION}/apache2/php.ini
Update


# After pear!!!
echo ""
echo ""
echo "-- php dev --"
sudo apt-get install -y --force-yes php${PHP_VERSION}-dev
Update


# maybe not need
#
# echo ""
# echo ""
# echo "-- PECL --"
# # sudo apt-get install -y --force-yes php-pecl
# pecl config-set php_ini /etc/php/${PHP_VERSION}/cli/php.ini
# Update

# It's probably too late but for others a solution is explained here : http://www.mkfoster.com/2009/01/04/how-to-install-a-php-pecl-extensionmodule-on-ubuntu/
# sudo apt-get update
# sudo apt-get install php-pear php5-dev
# sudo apt-get install libcurl3-openssl-dev
# Then,

# sudo pecl install pecl_http 


echo ""
echo ""
echo "-- Install xdebug --"
sudo pecl install xdebug
Update


echo "Setup PHP ${PHP_VERSION}"
sudo mv /etc/php/${PHP_VERSION}/apache2/php.ini /etc/php/${PHP_VERSION}/apache2/php.ini.bak
# sudo cp -d /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/apache2/php.ini
sudo cp -s /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/apache2/php.ini
sudo sed -i 's#;date.timezone\([[:space:]]*\)=\([[:space:]]*\)*#date.timezone\1=\2\"'"$timezone"'\"#g' /etc/php/${PHP_VERSION}/apache2/php.ini
sudo sed -i 's#display_errors = Off#display_errors = On#g' /etc/php/${PHP_VERSION}/apache2/php.ini
sudo sed -i 's#display_startup_errors = Off#display_startup_errors = On#g' /etc/php/${PHP_VERSION}/apache2/php.ini
sudo sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#g' /etc/php/${PHP_VERSION}/apache2/php.ini
sudo a2enmod php${PHP_VERSION}


sudo apt-get install -y --force-yes php${PHP_VERSION}-mcrypt
Update


echo ""
echo ""
echo "-- Install MySQL --"
sudo apt-get install -y --force-yes mysql-server
Update

echo "-- Enable access from guest machine --"
mysql -ulocalhost -uroot -proot -e "SHOW DATABASES;"
mysql -ulocalhost -uroot -proot -e "CREATE USER 'guest_user'@'localhost' IDENTIFIED BY 'guest_password'"
mysql -ulocalhost -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'guest_user'@'localhost' WITH GRANT OPTION"
mysql -ulocalhost -uroot -proot -e "CREATE USER 'guest_user'@'%' IDENTIFIED BY 'guest_password'"
mysql -ulocalhost -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'guest_user'@'%' WITH GRANT OPTION"
mysql -ulocalhost -uroot -proot -e "FLUSH PRIVILEGES"
sudo sed -i 's#skip-external-locking#\# skip-external-locking#g' /etc/mysql/my.cnf
sudo sed -i 's#bind-address#\# bind-address = 0.0.0.0 \##g' /etc/mysql/my.cnf
sudo service mysql reload


# skip-external-locking
#
# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
#bind-address           = 127.0.0.1
bind-address = 0.0.0.0




echo ""
echo ""
echo "-- Install Composer --"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
Update


echo ""
echo ""
echo "-- Install PHPUnit --"
wget https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar
sudo mv phpunit-${PHPUNIT_VERSION}.phar /usr/local/bin/phpunit
sudo chmod +x /usr/local/bin/phpunit
Update
phpunit --version


echo ""
echo ""
echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-english.tar.gz
sudo tar -xzvf phpMyAdmin-${PHPMYADMIN_VERSION}-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-${PHPMYADMIN_VERSION}-english.tar.gz
sudo mv /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-english/ /var/www/phpmyadmin

sudo service apache2 restart
