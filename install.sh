#!/bin/bash
#
# This scipt will install VilWisperer on a ubuntu 18.04 server
# And conect it to a openvas server for gettong scan reports
#
# @Mattias Hemmingsson matte.hemmingsson@gmail.com
# 

echo "Start install"

#Installing vulwisperer
export DEBIAN_FRONTEND=noninteractive & apt-get update && apt-get install tzdata  -y
apt-get update && apt-get install gettext-base  zlib1g-dev libxml2-dev libxslt1-dev git python python-pip -y


# Install and setip VulnWhisperer
cd /opt
git clone https://github.com/HASecuritySolutions/VulnWhisperer.git
cd /opt/VulnWhisperer
pip install -r /opt/VulnWhisperer/requirements.txt
python setup.py install


# Adding config
#COPY config/frameworks_openvas.ini /opt/VulnWhisperer/configs/frameworks_openvas.tmp
