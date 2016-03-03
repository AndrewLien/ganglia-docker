#!/bin/bash

echo -e "\nbuild gangalia master image...\n"
sudo docker build -t kiwenlau/gangalia-master master/.

echo -e "\nbuild gangalia slave image...\n"
sudo docker build -t kiwenlau/gangalia-slave slave/.


sudo docker rm -f $(sudo docker ps -aq) > /dev/null

echo -e "\nstart slave node..."
sudo docker run -d -p 8649:8649/udp --name slave kiwenlau/gangalia-slave

echo -e "\nstart master node..."
sudo docker run -d --name master -v /etc/ganglia/gmetad.conf:/etc/ganglia/gmetad.conf -v /var/lib/ganglia:/var/lib/ganglia --link slave:slave -p 80:80 kiwenlau/gangalia-master

echo ""