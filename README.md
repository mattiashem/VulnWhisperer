# VulWisperer install for ubuntu 18.04 Upgraded may work Ubuntu 2020 and openvas
This will install the vilWisperer on a ubuntu 18.04 server.
Config to connect to a openvas server to get reports and save to local disk.

## You need before starting the install

- Ip ore url to Openvas
- The port to openvasd (default 4000)
- Admin username
- Admin password
- /opt folder don't have any OLD VulWisperer folder !
- wget is installed (apt-get install wget)
- Have som scans inside openvas else it commes back empty

You also need to have a logstash running localy to read the logs and send them to elasticsearch.


## Test this before starting

- Is the port open tedt with a telnet

```
telnet IP_OPENVAS 4000
```
You should get a connections_establish
If we cant get a connections we need to find the port for openvas


## Install 

### step 1 Install and setup Vilwisperer

This command will install vulwispere on your ubuntu server. During the installation you will be asked questions

```
wget https://raw.githubusercontent.com/mattiashem/VulnWhisperer/master/install.sh -O install.sh && chmod +x install.sh && ./install.sh
```
After this command Vulwispere should be installed and setup to connect to openvas.
To fetch new reports regulare setup a cronjob 

```
30 * * * *  root    vuln_whisperer -c /opt/VulnWhisperer/configs/frameworks_openvas.ini  -s openvas
```
Your config file is 

```
/opt/VulnWhisperer/configs/frameworks_openvas.ini
```

To run manually to test

```
vuln_whisperer -c /opt/VulnWhisperer/configs/frameworks_openvas.ini  -s openvas
```

If you see that is runs without any problems you can move to step 2

### Step 2 Setup Logstash

Now wee need to get logstash to read the json filen an send them to elastic.
Append ore add this config to your logstash config.

```
# Author: Austin Taylor and Justin Henderson
# Email: austin@hasecuritysolutions.com
# Last Update: 03/04/2018
# Version 0.3

input {
  file {
    path => "/opt/VulnWhisperer/data/openvas/*.json"
    type => json
    codec => json
    start_position => "beginning"
    tags => [ "openvas_scan", "openvas" ]
    mode => "read"
    start_position => "beginning"
    file_completed_action => "delete"

  }
}

filter {
  if "openvas_scan" in [tags] {
    mutate {
      replace => [ "message", "%{message}" ]
      gsub => [
        "message", "\|\|\|", " ",
        "message", "\t\t", " ",
        "message", "    ", " ",
        "message", "   ", " ",
        "message", "  ", " ",
        "message", "nan", " ",
        "message",'\n',''
      ]
    }


    grok {
        match => { "path" => "openvas_scan_%{DATA:scan_id}_%{INT:last_updated}.json$" }
        tag_on_failure => []
    }

    mutate {
      add_field => { "risk_score" => "%{cvss}" }
    }

    if [risk] == "1" {
      mutate { add_field => { "risk_number" => 0 }}
      mutate { replace => { "risk" => "info" }}
    }
    if [risk] == "2" {
      mutate { add_field => { "risk_number" => 1 }}
      mutate { replace => { "risk" => "low" }}
    }
    if [risk] == "3" {
      mutate { add_field => { "risk_number" => 2 }}
      mutate { replace => { "risk" => "medium" }}
    }
    if [risk] == "4" {
      mutate { add_field => { "risk_number" => 3 }}
      mutate { replace => { "risk" => "high" }}
    }
    if [risk] == "5" {
      mutate { add_field => { "risk_number" => 4 }}
      mutate { replace => { "risk" => "critical" }}
    }

    mutate {
      remove_field => "message"
    }

    if [first_time_detected] {
      date {
        match => [ "first_time_detected", "dd MMM yyyy HH:mma 'GMT'ZZ", "dd MMM yyyy HH:mma 'GMT'" ]
        target => "first_time_detected"
      }
    }
    if [first_time_tested] {
      date {
        match => [ "first_time_tested", "dd MMM yyyy HH:mma 'GMT'ZZ", "dd MMM yyyy HH:mma 'GMT'" ]
        target => "first_time_tested"
      }
    }
    if [last_time_detected] {
      date {
        match => [ "last_time_detected", "dd MMM yyyy HH:mma 'GMT'ZZ", "dd MMM yyyy HH:mma 'GMT'" ]
        target => "last_time_detected"
      }
    }
    if [last_time_tested] {
      date {
        match => [ "last_time_tested", "dd MMM yyyy HH:mma 'GMT'ZZ", "dd MMM yyyy HH:mma 'GMT'" ]
        target => "last_time_tested"
      }
    }

    # TODO remove when @timestamp is included in event
    date {
      match => [ "last_updated", "UNIX" ]
      target => "@timestamp"
      remove_field => "last_updated"
    }
    mutate {
      convert => { "plugin_id" => "integer"}
      convert => { "id" => "integer"}
      convert => { "risk_number" => "integer"}
      convert => { "risk_score" => "float"}
      convert => { "total_times_detected" => "integer"}
      convert => { "cvss_temporal" => "float"}
      convert => { "cvss" => "float"}
    }
    if [risk_score] == 0 {
      mutate {
        add_field => { "risk_score_name" => "info" }
      }
    }
    if [risk_score] > 0 and [risk_score] < 3 {
      mutate {
        add_field => { "risk_score_name" => "low" }
      }
    }
    if [risk_score] >= 3 and [risk_score] < 6 {
      mutate {
        add_field => { "risk_score_name" => "medium" }
      }
    }
    if [risk_score] >=6 and [risk_score] < 9 {
      mutate {
        add_field => { "risk_score_name" => "high" }
      }
    }
    if [risk_score] >= 9 {
      mutate {
        add_field => { "risk_score_name" => "critical" }
      }
    }
    # Add your critical assets by subnet or by hostname. Comment this field out if you don't want to tag any, but the asset panel will break.
    if [asset] =~ "^10\.0\.100\." {
      mutate {
        add_tag => [ "critical_asset" ]
      }
    }
  }
}
output {
  if "openvas" in [tags] {
    stdout {
      codec => dots
    }
    elasticsearch {
      hosts => [ "elasticsearch:9200" ]
      index => "logstash-vulnwhisperer-%{+YYYY.MM}"
    }
  }
}
```

Here at the end of the file you can controll the output to elastic.
If you cant merge this into your running logstash. You can start a secound logstash to read the files and send them to elastic

```
logstash -f logstash-openvas.conf
```
