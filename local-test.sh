#!/bin/bash

echo -e "\nbuild gangalia master image...\n"
sudo docker build -t kiwenlau/gangalia-master master/.

echo -e "\nbuild gangalia slave image...\n"
sudo docker build -t kiwenlau/gangalia-slave slave/.


sudo docker rm -f $(sudo docker ps -aq) > /dev/null

echo -e "\nstart slave node..."
sudo docker run -d -p 8649:8649/udp --name slave kiwenlau/gangalia-slave > /dev/null

CURRENT_DIRECTORY=`pwd`

sudo rm -rf gangalia
sudo mkdir -p ganglia/rrds
sudo chown -R 999:999 ganglia
sudo chmod -R 777 ganglia

sudo sh -c "cat > gmetad.conf <<EOL
data_source \"cluster1\" slave:8649
setuid_username \"ganglia\"
case_sensitive_hostnames 0
EOL"


echo -e "\nstart master node..."
sudo docker run -d --name master \
                -v /var/lib/ganglia:/var/lib/ganglia \
                -v $CURRENT_DIRECTORY/gmetad.conf:/etc/ganglia/gmetad.conf \
                --link slave:slave  \
                -p 80:80 \
                kiwenlau/gangalia-master > /dev/null


echo ""