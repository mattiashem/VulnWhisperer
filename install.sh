#!/bin/bash
#
# This scipt will install VilWisperer on a ubuntu 18.04 server
# And conect it to a openvas server for gettong scan reports
#
# @Mattias Hemmingsson matte.hemmingsson@gmail.com
# 

echo "Start install"
echo "Lets setup some values first"
echo "What url / ip to openvas server: (type 127.0.0.1 for default)"
read openvas_url
export OPENVAS_URL=$openvas_url

echo "Openvas Port: (type 4000 for default)"
read openvas_port
export OPENVAS_PORT=$openvas_port

echo "Openvas username: (type admin for default)"
read openvas_user
export OPENVAS_USERNAME=$openvas_user

echo "Openvas passwprd (type admin for default)"
read openvas_pass
export OPENVAS_PASSWORD=$openvas_pass


#Installing vulwisperer
export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install tzdata  -y
apt-get update && apt-get install gettext-base wget zlib1g-dev libxml2-dev libxslt1-dev git python python-pip -y


# Install and setip VulnWhisperer
cd /opt
git clone https://github.com/HASecuritySolutions/VulnWhisperer.git
cd /opt/VulnWhisperer
pip install -r /opt/VulnWhisperer/requirements.txt
python setup.py install


# Adding config
echo "Setting up config"
wget https://raw.githubusercontent.com/mattiashem/VulnWhisperer/master/config/frameworks_openvas.ini -O /tmp/frameworks_openvas.ini
envsubst < /tmp/frameworks_openvas.ini > /opt/VulnWhisperer/configs/frameworks_openvas.ini
cat /opt/VulnWhisperer/configs/frameworks_openvas.ini
echo "Letst see if the config works by starting it up"
vuln_whisperer -c /opt/VulnWhisperer/configs/frameworks_openvas.ini  -s openvas
echo "Now you should have som json file in this folder"
ls -l /opt/VulnWhisperer/data/openvas/*.json
echo "If you dont se any json files here look in the gitrep for trubelshout"

