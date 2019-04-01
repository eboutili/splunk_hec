Puppet/Splunk Demo Installation and Configuration
==============

Install a Splunk Demo Server and the Puppet Report Viewer (scripted)
-----------

Copy the 
[Splunk installation script](https://github.com/eboutili/splunk_hec/blob/master/demo_splunk.sh) 
to a temporary directory on the Puppet Master node and run it as root or using sudo. 

The script downloads and installs the Docker version of Splunk Enterprise
(includes a trial license). Then it runs the container and uses `docker exec`
to install the Puppet Report Viewer add-on.

Create a HEC input for puppet summaries
-----------
Log into the new Splunk Server's Console: `http://<your-master-ip>:8000`
(Note: http not https)
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

(Note: This one _is_ https)

(Since this is a demo IP address, you may have to click through a security certificate warning)

Browse to the Master configuration tab:
- Login/Password: admin/puppetlabs

Select Classification in the left sidebar.

Expand the PE Infrastructure group (click the `+` sign)

Click `Master` and go to the `Configuration` tab

Under `Classes`, add a new class called `splunk_hec`

Click `Add Class`

Click `Parameter name` to see the list of available parameters

Select `server` and set the value to `"localhost"` (include the double quotes)

Click `Add Parameter`

Click `Parameter name` again, this time select `token`

In the value field, paste the token created when you defined a new HEC collectory on the Splunk Server
in double quotes.

### Command line step

Log into the command line of the Puppet Master node:

`ssh -i ~/student.pem centos@<your-master-ip>`

Edit the puppet server's configuration file:
`sudo nano /etc/puppetlabs/puppet/puppet.conf`

Go the line that says: `reports = puppetdb`
Change it to: `reports = puppetdb,splunk_hec`

Save and exit the editor
`^X -> Y -> <Return>`

Do a puppet run:

`sudo puppet agent -t`