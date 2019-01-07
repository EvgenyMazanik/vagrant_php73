#!/usr/bin/env bash


HOST_PATH=/host/


echo ""
echo ""
echo "-- Check /config/etc/apache2/sites-available/individual.conf --" 
if [ -f /config/etc/apache2/sites-available/individual.conf ]; then
            
    cp /config/etc/apache2/sites-available/individual.conf /etc/apache2/sites-available/individual.conf
    sudo a2ensite individual 

else
    
    sudo a2dissite individual 
    
fi


echo ""
echo ""
echo "-- Check /vagrant/config/etc/apache2/sites-available/common.conf --" 
if [ -f /vagrant/config/etc/apache2/sites-available/common.conf ]; then
            
    echo "-- Found /vagrant/config/etc/apache2/sites-available/common.conf --" 
    cp /vagrant/config/etc/apache2/sites-available/common.conf /etc/apache2/sites-available/common.conf
    sudo a2ensite common 

else
    
    echo "-- Not Found /vagrant/config/etc/apache2/sites-available/common.conf --" 
    sudo a2dissite common 
    
fi



# create and enable new Virtual Hosts
for directory_path in ${HOST_PATH}* ; do

    if [ -d ${directory_path} ]; then

        echo ""
        echo "Found $directory_path directory."
        directory_name=`basename "$directory_path"`;

        if [ -f ${directory_path}/app/env/apache2-vhost.conf ]; then
            
            conf_from_path=${directory_path}/app/env/apache2-vhost.conf
            
        else 
            if [ -f ${directory_path}/nano/env/apache2-vhost.conf ]; then
            
                conf_from_path=${directory_path}/nano/env/apache2-vhost.conf
                
            else 

                if [ -f ${directory_path}/.dev/env/apache2-vhost.conf ]; then
                
                    conf_from_path=${directory_path}/.dev/env/apache2-vhost.conf
                    
                else
                
                    conf_from_path=/vagrant/blanks/.dev/env/apache2-vhost.conf
                    
                fi
            fi
        fi
        
        public_path=""
        if [ -d ${directory_path}/public ]; then
            public_path=${directory_path}/public
        elif [ -d ${directory_path}/www ]; then
            public_path=${directory_path}/www
        else
            public_path=${directory_path}
        fi
        echo "directory_path: ${directory_path}"
        echo "directory_name: ${directory_name}"
        echo "conf: /etc/apache2/sites-available/${directory_name}.conf"
        echo "public_path: ${public_path}"
        
        
       cp -rf ${conf_from_path} /etc/apache2/sites-available/${directory_name}.conf
        
        sed -i "s|{HOST_PATH}|$HOST_PATH|g" /etc/apache2/sites-available/${directory_name}.conf
        sed -i "s|{DOMAIN_NAME}|$directory_name|g" /etc/apache2/sites-available/${directory_name}.conf
        sed -i "s|{PUBLIC_PATH}|$public_path|g" /etc/apache2/sites-available/${directory_name}.conf
        
        sudo a2ensite ${directory_name} 

    fi

done


echo ""
echo ""
echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

