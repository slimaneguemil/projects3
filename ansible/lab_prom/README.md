# Cloud Alchemy demo monitoring site

[![Build Status](https://travis-ci.org/cloudalchemy/demo-site.svg?branch=master)](https://travis-ci.org/cloudalchemy/demo-site)
[![License](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg)](https://opensource.org/licenses/MIT)
[![IRC](https://img.shields.io/badge/irc.freenode.net-%23cloudalchemy-yellow.svg)](https://kiwiirc.com/nextclient/#ircs://irc.freenode.net/#cloudalchemy)

## [demo.cloudalchemy.org](https://demo.cloudalchemy.org)

This repository provides an integration testing suite for our ansible roles as well as a demo site for [grafana](https://github.com/grafana/grafana), [prometheus](https://github.com/prometheus/prometheus), [alertmanager](https://github.com/prometheus/alertmanager) and [node_exporter](https://github.com/prometheus/node_exporter) (possibly more in the future).
Site is provisioned with ansible running every day and on almost all commits to master branch. Everything is fully automated with travis ci pipeline. If you want to check `ansible-playbook` output, go to [last build](https://travis-ci.org/cloudalchemy/demo-site) or visit [ARA Records Ansible page](https://demo.cloudalchemy.org/ara).

Have a look at the configuration file [group_vars/all/vars](group_vars/all/vars).

## Applications

All applications should be running on their default ports.

| App name          | Address (HTTP)                                       | Address (HTTPS)                                           | Status                       |  Uptime                     |
|-------------------|------------------------------------------------------|-----------------------------------------------------------|-----------------------------|-----------------------------|
| node_exporter     | [demo.cloudalchemy.org:9100][node_exporter_http]     | [node.demo.cloudalchemy.org][node_exporter_https]         | ![node_exporter_status]     | ![node_exporter_uptime]     |
| snmp_exporter     | [demo.cloudalchemy.org:9116][snmp_exporter_http]     | [snmp.demo.cloudalchemy.org][snmp_exporter_https]         | ![snmp_exporter_status]     | ![snmp_exporter_uptime]     |
| blackbox_exporter | [demo.cloudalchemy.org:9115][blackbox_exporter_http] | [blackbox.demo.cloudalchemy.org][blackbox_exporter_https] | ![blackbox_exporter_status] | ![blackbox_exporter_uptime] |
| prometheus        | [demo.cloudalchemy.org:9090][prometheus_http]        | [prometheus.demo.cloudalchemy.org][prometheus_https]      | ![prometheus_status]        | ![prometheus_uptime]        |
| alertmanager      | [demo.cloudalchemy.org:9093][alertmanager_http]      | [alertmanager.demo.cloudalchemy.org][alertmanager_https]  | ![alertmanager_status]      | ![alertmanager_uptime]      |
| grafana           | [demo.cloudalchemy.org:3000][grafana_http]           | [grafana.demo.cloudalchemy.org][grafana_https]            | ![grafana_status]           | ![grafana_uptime]           |

## Important notice

This repository consists of two playbooks:
  - [site.yml](site.yml) - which deploys basic prometheus/grafana stack without additional http proxies and with software listening on default ports
  - [extras.yml](extras.yml) - adds influxdb as a long-term storage and deploys caddy http proxy. This will allow HTTPS connections to services like prometheus

Such setup causes that mose of services can be accessed in two ways. As an example, prometheus can be accessed via:
  - **http**://demo.cloudalchemy.org:9090 - default way
  - **https**://prometheus.demo.cloudalchemy.org - workaround which in backgroud communicates with prometheus via insecure, "default" channel mentioned above

This workaround was needed to solve issue [#13](https://github.com/cloudalchemy/demo-site/issues/13) and still provide a playbook which could be used by everyone - [site.yml](site.yml).

## Run yourself

You can easily run such setup yourself without much knowledge how any part of this works. You just need to do two things:

#### Change ansible inventory

First of all you need to configure your inventory, ours is located in [`hosts`](hosts) file. Here you set up your target hosts by changing value of `ansible_host` variable. Also here you can exclude parts of this demo site, so if you don't need our website, you just remove this part:

```
[web]
demo
```

Accordingly you can exclude grafana, prometheus, or influxdb.

#### Change passwords

For security measures we encrypted some of our passwords, but it is easy to use yours! You can do it by replacing a file located at [`group_vars/all/vault`](group_vars/all/vault_old) with following content:

```
vault_grafana_password: <<INSERT_YOUR_GRAFANA_PASSWORD>>
vault_influxdb_password: <<INSERT_YOUR_INFLUXDB_PASSWORD>>
```

You need to specify both even if you don't use grafana nor influxdb. You can look over [`group_vars/all/vault`](group_vars/all/vars) to find why.

#### Run as usual Ansible playbook

```bash
# Download roles
ansible-galaxy install -r roles/requirements.yml

# Run playbook
ansible-playbook site.yml
# or when using vault encrypted variables
ansible-playbook --vault-id @prompt site.yml
```

# 

[![DigitalOcean](https://snapshooter.io/powered_by_digital_ocean.png)](https://digitalocean.com)



[node_exporter_http]: http://demo.cloudalchemy.org:9100
[node_exporter_https]: https://node.demo.cloudalchemy.org
[node_exporter_status]: https://img.shields.io/uptimerobot/status/m779739001-48f8ed6c3aa6f23da1ec11e2.svg
[node_exporter_uptime]: https://img.shields.io/uptimerobot/ratio/7/m779739001-48f8ed6c3aa6f23da1ec11e2.svg

[snmp_exporter_http]: http://demo.cloudalchemy.org:9116
[snmp_exporter_https]: https://snmp.demo.cloudalchemy.org
[snmp_exporter_status]: https://img.shields.io/uptimerobot/status/m779739006-f784bd36e07d328bfacb6d17.svg
[snmp_exporter_uptime]: https://img.shields.io/uptimerobot/ratio/7/m779739006-f784bd36e07d328bfacb6d17.svg

[blackbox_exporter_http]: http://demo.cloudalchemy.org:9115
[blackbox_exporter_https]: https://blackbox.demo.cloudalchemy.org
[blackbox_exporter_status]: https://img.shields.io/uptimerobot/status/m779739004-8447f4012a129e08df4db247.svg
[blackbox_exporter_uptime]: https://img.shields.io/uptimerobot/ratio/7/m779739004-8447f4012a129e08df4db247.svg

[prometheus_http]: http://demo.cloudalchemy.org:9090
[prometheus_https]: https://prometheus.demo.cloudalchemy.org
[prometheus_status]: https://img.shields.io/uptimerobot/status/m779739002-6049a4d9177bdf92d7dce7d9.svg
[prometheus_uptime]: https://img.shields.io/uptimerobot/ratio/7/m779739002-6049a4d9177bdf92d7dce7d9.svg

[alertmanager_http]: http://demo.cloudalchemy.org:9093
[alertmanager_https]: https://alertmanager.demo.cloudalchemy.org
[alertmanager_status]: https://img.shields.io/uptimerobot/status/m779739005-687f76da143b768d378502f8.svg
[alertmanager_uptime]: https://img.shields.io/uptimerobot/ratio/7/m779739005-687f76da143b768d378502f8.svg

[grafana_http]: http://demo.cloudalchemy.org:3000
[grafana_https]: https://grafana.demo.cloudalchemy.org
[grafana_status]: https://img.shields.io/uptimerobot/status/m779739003-21ce43d565a95d31564b438d.svg
[grafana_uptime]: https://img.shields.io/uptimerobot/ratio/7/m779739003-21ce43d565a95d31564b438d.svg
