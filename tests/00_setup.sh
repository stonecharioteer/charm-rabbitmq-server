#!/bin/sh

# Install Juju Amulet and any other applications that are needed for the tests.

set -x

# Check if amulet is installed before adding repository and updating apt-get.
dpkg -s amulet
if [ $? -ne 0 ]; then 
    sudo add-apt-repository -y ppa:juju/stable
    sudo apt-get update 
    sudo apt-get install -y amulet
fi

# Install any additional python packages, or software here.
sudo apt-get install -y python python-pika python3-requests

sudo pip3 install python3-pika
