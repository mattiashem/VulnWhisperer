#!/bin/bash
#
# This scipt will install VilWisperer on a ubuntu 18.04 server
# And conect it to a openvas server for gettong scan reports
#
# @Mattias Hemmingsson matte.hemmingsson@gmail.com
# 

echo "Start install"

echo "Lets setup some values first"
echo "What url / ip to openvas server: (127.0.0.1)"
read openvas_url
export OPENVAS_URL=openvas_url

echo "Opnevas Port: (4000)"
read openvas_port
export OPENVAS_PORT=openvas_port

echo "Openvas username: (admin)"
read openvas_user
export OPENVAS_USERNAME=openvas_user

echo "Openvas passwprd (admin)"
read openvas_pass
export OPENVAS_PASSWORD=openvas_pass

#Installing vulwisperer
export DEBIAN_FRONTEND=noninteractive & apt-get update && apt-get install tzdata  -y
apt-get update && apt-get install gettext-base  wget zlib1g-dev libxml2-dev libxslt1-dev git python python-pip -y


# Install and setip VulnWhisperer
##cd /opt
##git clone https://github.com/HASecuritySolutions/VulnWhisperer.git
##cd /opt/VulnWhisperer
##pip install -r /opt/VulnWhisperer/requirements.txt
##python setup.py install


# Adding config
echo "Setting up config"
wget https://raw.githubusercontent.com/mattiashem/VulnWhisperer/master/config/frameworks_openvas.ini -o /tmo/frameworks_openvas.ini
envsubst < /tmo/frameworks_openvas.ini > 
cat /opt/VulnWhisperer/configs/frameworks_openvas.ini
