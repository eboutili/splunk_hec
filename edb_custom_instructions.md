puppet-splunk_hec
==============

Description
-----------

Puppet collects a wide variety of useful information about the servers it manages. When you have key Puppet data in Splunk, you can save time and make richer analyses. For example you can have Splunk send an alert if Puppet sees unexpected change on a server. To make this possible this is a Puppet report processor designed to send a report summary of useful information to the [Splunk HTTP Endpoint Collector "HEC"](http://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector) service. These summaries are designed to be informative but also not too verbose to make logging a burden to the end user. The summaries are meant to be small but sufficient to determine if a Puppet run was successful on a node, and to include metadata such as code-id, transaction-id, and other details to allow for more detailed actions to be done.

It is best used with the [Puppet Report Viewer](https://splunkbase.splunk.com/app/4413/) Splunk addon that adds sourcetypes to make ingesting this data easier into Splunk. Sourcetypes can also be associated with specifc HEC tokens to make event viewing/processing easier. 

Because Puppet and Bolt excel at taking action, the Report Viewer also adds an actionable alert for Puppet Enterprise users. Using the data from a `puppet:summary` event, the Detailed Report Builder actionable alert will create a new event with the type of `puppet:detailed`. These events contain information such as the node in questions, its facts, the resource_events from the node, and links to relevant reports in the Puppet Enterprise Console.

There are two Tasks included in this module, `splunk_hec:bolt_apply` and `splunk_hec:bolt_result` that provide similar data for Bolt Plans to submit data to Splunk. Also included are Plans showing example useage of the Tasks.


Requirements
------------

* Puppet or Puppet Enterprise
* Splunk

This was tested on both Puppet Enterprise 2018.1.4 & Puppet 6, using stock gems of yaml, json, net::https

Report Processor Installation & Usage
--------------------

The steps below will help install and troubleshoot the report processor on a single Puppet Master, including manual steps to configure a puppet-server, and to use the included splunk_hec class.

1. Install the Puppet Report Viewer Addon in Splunk. This will import the needed sourcetypes that make setting up the HEC easier in the next steps, and also some overview dashboards that make it a lot easier to see if you're sending Puppet run reports into Splunk.

2. Create a Splunk HEC Token (preferably named `puppet:summary` and using the sourcetype `puppet:summary` from the Report Viewer addon). Follow the steps provided by Splunk's [Getting Data In Guide](http://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector) if you are new to HTTP Endpoint Collectors.

3. Install this Puppet module in the environment that manages your Puppet Servers are using (probably `production`)

4. Run `puppet plugin download` on your Puppet Server to sync the content

(Steps 5 and 6 are for testing/troubleshooting your configuration settings. Otherwise you can skip to step 7)

5. Create a `/etc/puppetlabs/puppet/splunk_hec.yaml` (see examples directory for one) adding your Splunk Server & Token from step 1
  - You can add 'timeout' as an optional parameter, default value is 2 for both open and read sessions, so take value x2 for real world use
  - The same is true for port, defaults to 8088 if none is provided
  - Provide a `puppetdb\_callback\_hostname` variable if the hostname that Splunk will use to lookup further information about a report is different than the Puppet Server processing the reports (i.e., multiple servers, load balancer, external dns name vs internal, etc.) This defaults to the certname of the Puppet Server processing the report. Note that this feature has yet to be enabled in the Puppet Report Viewer.

  ```
---
"server" : "splunk-dev.testing.internal"
"token" : "13311780-EC29-4DD0-A796-9F0CDC56F2AD"
```

6. Run `puppet apply -e 'notify { "hello world": }' --reports=splunk_hec` from the Puppet Server, this will load the report processor and test your configuration settings without actually modifying your Puppet Server's running configuration. If you are using the Puppet Report Viewer app in Splunk then you will see the page update with new data. If not, perform a search by the sourcetype you provided with your HEC configuration.

7. Provide the working parameters / values to the splunk_hec class and use it in a profile or add it to the PE Masters subgroup of PE Infrastructure in the classification section of the console. Run Puppet on the MoM first (because it is the Puppet Server all the other compile masters are using) before running puppet on the other compile masters. This will restart the puppet-server processor, so stagger the runs to prevent an outage.

### Manual steps:

- Add `splunk_hec` to `/etc/puppetlabs/puppet/puppet.conf` reports line under the master's configuration block
```
[master]
node_terminus = classifier
storeconfigs = true
storeconfigs_backend = puppetdb
reports = puppetdb,splunk_hec
```

- Restart the puppet-server process for it to reload the configuration and the plugin

- Run `puppet agent -t` somewhere, if you are using the suggested name, use `source="http:puppet-report-summary"` in your Splunk search field to show the reports as they arrive

