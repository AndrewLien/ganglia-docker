#!/bin/bash

MASTER_IP=192.168.59.1
SLAVE_IP=(192.168.59.2)

# sudo rm -rf /var/lib/ganglia
# sudo mkdir -p /var/lib/ganglia/rrds
# sudo chown -R 999:999 /var/lib/ganglia

 # start slave container
for (( i = 0; i < 1; i++ )); do
         sudo docker -H tcp://${SLAVE_IP[$i]}:4000 rm -f $(sudo docker -H tcp://${SLAVE_IP[$i]}:4000 ps -aq) > /dev/null
         echo -e "\nstart slave$i container..."
         sudo docker -H tcp://${SLAVE_IP[$i]}:4000 run -d --net=host --name gangalia-slave$i \
                                                       -v /etc/localtime:/etc/localtime:ro \
                                                       -e MASTER_IP=$MASTER_IP \
                                                       kiwenlau/ganglia \
                                                       supervisord --configuration=/etc/supervisor/conf.d/ganglia-slave.conf > /dev/null
done

echo -e "\nstart master node..."
sudo docker rm -f $(sudo docker ps -aq) > /dev/null
sudo docker run -d --net=host --name ganglia-master \
                -v /etc/localtime:/etc/localtime:ro \
                -e MASTER_IP=$MASTER_IP \
                kiwenlau/ganglia \
                supervisord --configuration=/etc/supervisor/conf.d/ganglia-master.conf > /dev/null



echo ""

