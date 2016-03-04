#!/bin/bash

MASTER_IP=192.168.59.1

SLAVE_IP=(192.168.59.2)

CURRENT_DIRECTORY=`pwd`

sudo sh -c "cat > gmetad.conf <<EOL
data_source \"cluster1\" 192.168.59.2:8649
setuid_username \"ganglia\"
case_sensitive_hostnames 0
EOL"

echo -e "\nstart master node..."
sudo docker rm -f $(sudo docker ps -aq) > /dev/null
sudo docker run -d --net=host --name master \
                -v /var/lib/ganglia:/var/lib/ganglia \
                -v $CURRENT_DIRECTORY/gmetad.conf:/etc/ganglia/gmetad.conf \
                kiwenlau/gangalia-master > /dev/null

# start slave container
for (( i = 0; i < 1; i++ )); do
        sudo docker -H tcp://${SLAVE_IP[$i]}:4000 rm -f $(sudo docker -H tcp://${SLAVE_IP[$i]}:4000 ps -aq) > /dev/null
        echo -e "\nstart slave$i container..."
        sudo docker -H tcp://${SLAVE_IP[$i]}:4000 run -d --net=host --name slave$i kiwenlau/gangalia-slave  > /dev/null
done

echo ""

