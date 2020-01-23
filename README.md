# VilWisperer install for ubuntu 18.04 and openvas
This will install the vilWisperer on a ubuntu 18.04 server.
Config to connect to a openvas serve to get reports and save to local disk.

## You need before starting the install

- Ip ure url to Openvas
- The port to openvasd (default 4000)
- Admin username
- Admin password
- /opt folder dont have any OLD VulWisperer folder !

You also need to have a logstash running localy to read the vilwisperer logs and send them to elasticsearch.


## Test this before starting

- Is the port open tedt with a telnet

```
telnet IP_OPENVAS 4000
```
You should get a connections_establish


## Install 

### step 1 Install and setup Vilwisperer

This command will install vulwispere on your ubuntu server. During the installation you will be asked questions