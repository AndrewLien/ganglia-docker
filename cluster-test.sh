#!/bin/bash

MASTER_IP=192.168.59.1

SLAVE_IP=(192.168.59.2)

echo -e "\nstart master node..."
sudo docker rm -f $(sudo docker ps -aq) > /dev/null
sudo docker run -d --name master  -v /var/lib/ganglia:/var/lib/ganglia --net=host kiwenlau/gangalia-master

echo -e "\nstart slave node..."
sudo docker run -d -p 8649:8649/udp --name slave kiwenlau/gangalia-slave

# start slave container
for (( i = 0; i < 3; i++ )); do
        sudo docker -H tcp://${SLAVE_IP[$i]}:4000 rm -f $(sudo docker -H tcp://${SLAVE_IP[$i]}:4000 ps -aq) > /dev/null
        echo "start slave$i container..."
        sudo docker -H tcp://${SLAVE_IP[$i]}:4000 run -v /etc/localtime:/etc/localtime:ro -v /var/lib/docker/aufs:/var/lib/docker/aufs -v /var/lib/docker/image:/var/lib/docker/image -it -d --net=host --privileged --name=swarm-slave -e "INTERFACE=$INTERFACE" -e "GALAXY_IP=$GALAXY_IP" -e "MASTER_IP=$MASTER_IP" kiwenlau/swarm supervisord --configuration=/etc/supervisor/conf.d/swarm-slave.conf  > /dev/null
done

