Foundational Partner Training Lab
==============

Puppet/Splunk Demo Installation and Configuration
==============

## 1. Install a Splunk Demo Server and the Puppet Report Viewer (scripted)

Copy the 
[Splunk installation script](https://github.com/eboutili/splunk_hec/blob/master/demo_splunk.sh) 
to a temporary directory on your Puppet Master server and run the script as root (or using sudo). 
Login with: `ssh -i ~/student.pem centos@<your-master-ip>`

The script downloads and installs the Docker version of Splunk Enterprise (includes a trial license), then it runs the container and uses `docker exec` to install the Puppet Report Viewer add-on.

Note: Since the Puppet Console and the Splunk Console are installed on the same server, they'll
use the same IP with Splunk on port 8000 (http) and Puppet on port 443 (https)

## 2. Create a HEC input for puppet summaries

Log into the new Splunk Server's Console on port 8000: `http://<your-master-ip>:8000`

(Note: http not https)

Login/Password: admin/puppetlabs

Browse to the HTTP Event Collector configuration screen 

`Settings -> Data Input -> HTTP Event Collector -> Global Settings`

- Click `Enabled` and `Save`

- Click `New Token`

- Enter the following in the `Name` Field: `puppet:summary`

- Click `Next`

- Click `Select` then `Select Source Type`

- Enter (or select): `puppet:summary`

- Click `Review` and check for typos. Click `Submit`

A new token is generated. (You'll copy this to the Puppet Master in the next set of steps.)

## 3. Configure the HEC token and Splunk DNS name on the Puppet Master side

Log into the Puppet Console: `https://<your-master-ip>`

(Note: This one _is_ https)

(Since this is a demo IP address, you may have to click through a security certificate warning)

Login/Password: admin/puppetlabs

Browse to the Master's configuration tab

- Select Classification in the left sidebar.

- Expand the PE Infrastructure group (click the `+` sign)

- Click `Master` and go to the `Configuration` tab

Under `Classes`, add a new class called `splunk_hec`

Click `Add Class`

Click `Parameter name` to see the list of available parameters

Select `server` and set the value to `"localhost"` (include the double quotes)

Click `Add Parameter`

Click `Parameter name` again, this time select `token`

In the value field, paste the token created (above) (when you defined `puppet:summary` HEC collector on the Splunk Server
in double quotes.

Click `Add Parameter`

Check for typos, then Click `Commit 1 Change`

These two parameters, `token` and `server`, are the only required ones.


## 4. Command line step

*Note*: If you're doing this as part of the Channel Partner SE training, the
following change has already been made (scripted when the VM was launched)
You should still follow the steps, but the change will already be there.

Log into the command line of the Puppet Master node

`ssh -i ~/student.pem centos@<your-master-ip>`

Edit the puppet server's configuration file:
`sudo nano /etc/puppetlabs/puppet/puppet.conf` 

(vi is also available of course)

Go the line that says: `reports = puppetdb`
Change it to: `reports = puppetdb,splunk_hec`

Save and exit the editor
`^X -> Y -> <Return>`
