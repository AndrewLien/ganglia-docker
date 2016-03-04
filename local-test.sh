#!/bin/bash

echo -e "\nbuild ganglia image...\n"
sudo docker build -t kiwenlau/ganglia ganglia/.

sudo docker rm -f $(sudo docker ps -aq) > /dev/null

CURRENT_DIRECTORY=`pwd`

echo -e "\nstart slave node..."
sudo docker run -d -p 8649:8649/udp --name ganglia-slave \
     -v $CURRENT_DIRECTORY/gmetad.conf:/etc/ganglia/gmetad.conf \
     kiwenlau/ganglia \
     supervisord --configuration=/etc/supervisor/conf.d/ganglia-slave.conf > /dev/null

sudo sh -c "cat > gmetad.conf <<EOL
data_source \"cluster1\" ganglia-slave:8649
setuid_username \"ganglia\"
case_sensitive_hostnames 0
EOL"


echo -e "\nstart master node..."
sudo docker run -d --name ganglia-master \
                -v /var/lib/ganglia:/var/lib/ganglia \
                -v $CURRENT_DIRECTORY/gmetad.conf:/etc/ganglia/gmetad.conf \
                --link ganglia-slave:ganglia-slave  \
                -p 80:80 \
                kiwenlau/ganglia \
                supervisord --configuration=/etc/supervisor/conf.d/ganglia-master.conf > /dev/null
                > /dev/null


echo ""