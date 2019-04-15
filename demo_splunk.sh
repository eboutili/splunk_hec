#!/bin/bash
## Splunk installation script
## Tested on centos 7
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-18.06.2.ce-3.el7
systemctl enable docker
systemctl start docker
cd /root
cat > ./Dockerfile << "EOF"
FROM splunk/splunk:latest
RUN sudo apt-get update && sudo apt-get install -y git
ENV SPLUNK_START_ARGS --accept-license
ENV SPLUNK_PASSWORD puppetlabs
EOF
docker build -t splunkdemo_i .
docker run --name splunkdemo_c --restart always -d -p 8000:8000 -p 8088:8088 splunkdemo_i
# docker exec splunkdemo_c bash -c 'sudo wget https://github.com/puppetlabs/TA-puppet-report-viewer/archive/1.3.5.tar.gz -O - | gunzip -c - | tar -C /opt/splunk/etc/apps -xf -'
docker exec splunkdemo_c bash -c 'sudo wget https://github.com/puppetlabs/TA-puppet-report-viewer/archive/1.3.5.tar.gz -O - | sudo gunzip -c - | sudo tar -C /opt/splunk/etc/apps -xf -'
