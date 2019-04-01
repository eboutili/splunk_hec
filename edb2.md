Puppet/Splunk Demo Installation and Configuration
==============

Install a Splunk Demo Server and the Puppet Report Viewer (scripted)
-----------

Copy the Containerized Splunk installation script to a temporary directory on
the Puppet Master server and run it as root or using sudo.

Create a HEC input for puppet summaries
-----------
Log into the new Splunk Server: `http://<your-master-ip>:8000`
- Login/Password: admin/puppetlabs

Browse to where you can enable the HEC collector and create a new token (for receiving puppet data)

`Settings -> Data Input -> http Event Collector -> Global Settings`

Click `Enabled` and `Save`

Click `New Token`

- Enter the following in the `Name` Field: `puppet:summary`

Click `Next`

Click `Select` then `Select Source Type`

Click `Review` and check for typos. Click `Submit`

A new token is generated. (You'll copy this to the Puppet Master later.)

Install splunk_hec module in Puppet environment and configure with the HEC token and Splunk Server
------------
Log into the Puppet Master: `https://<your-master-ip>`

(Since this is a temporary server/IP, you may have to click through a security certificate warning)

Browse to the Master configuration tab:
- Login/Password: admin/puppetlabs

Select Classification in the left sidebar.

`Classification -> <Expand the Master Group (click the + sign)> -> Configuration`

Expand the PE Infrastructure group (click the + sign)

Click `Master` and go to the `Configuration` tab

Under `Classes`, add a new class called `splunk_hec`

Click `Add Class`

Define two parameters: (leave the others undefined)
- server: localhost
- token: `<token by the collector you defined above>`

Log into the command line of the Puppet Master server:

`ssh -i ~/student.pem centos<your-master-ip>`

Edit the puppet server configuration file:
`nano /etc/puppetlabs/puppet/puppet.conf`

Change this line:

Old:

`report`

New:

`report,splunk_hec`

Save and exit the editor
`^X`

Do a puppet run:

`puppet agent -t`

