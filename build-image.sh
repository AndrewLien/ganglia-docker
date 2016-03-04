#!/bin/bash

echo -e "\nbuild ganglia image...\n"
sudo docker build -t kiwenlau/ganglia ganglia/.

echo ""
