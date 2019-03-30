#!/bin/bash
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
ENV GITHUB_URL https://github.com/puppetlabs
ENV APP3 TA-puppet-report-viewer
EOF
docker build -t splunkdemo_i .
docker run --name splunkdemo_c --restart always -d -p 8000:8000 -p 8088:8088 splunkdemo_i
