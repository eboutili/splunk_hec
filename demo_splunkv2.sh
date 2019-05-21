!/bin/bash
## Tested on centos 7
#                      - Provision Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-18.06.2.ce-3.el7
systemctl enable docker
systemctl start docker
#                      - Provision Splunk Enterprise -- specifically the Docker version maintained by Splunk)
cd /root
cat > ./Dockerfile << "EOF"
FROM splunk/splunk:7.2.6
# RUN sudo apt-get update && sudo apt-get install -y git
ENV APPSDIR $SPLUNK_HOME/etc/apps
ENV SPLUNK_START_ARGS --accept-license
ENV SPLUNK_PASSWORD puppetlabs
RUN sudo apt-get update
#                       - Download the Puppet app archive file and the configuration ini file.
RUN sudo wget -O /tmp/inputs.conf https://raw.githubusercontent.com/eboutili/splunk_hec/master/inputs.conf
RUN sudo wget -O /tmp/1.3.5.tar.gz https://github.com/puppetlabs/TA-puppet-report-viewer/archive/1.3.5.tar.gz
EOF
docker build -t splunkdemo_i .
docker run --name splunkdemo_c --restart always -d -p 8000:8000 -p 8088:8088 splunkdemo_i
echo "sleeping 30 seconds..."
sleep 30
#                       - Deploy the files dowloaded above (Puppet app and configuration file)
docker exec splunkdemo_c bash -c 'sudo gunzip -c /tmp/1.3.5.tar.gz | sudo tar -C $APPSDIR -xf -'
docker exec splunkdemo_c bash -c 'sudo cp /tmp/inputs.conf $APPSDIR/TA-puppet-report-viewer-1.3.5/local/inputs.conf'
#                       - Apparently this isn't necessary... happens automatically
# docker exec splunkdemo_c bash -c 'sudo $SPLUNK_HOME/bin/splunk restart'
