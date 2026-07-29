![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](../../LICENSE)
[![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **metrics_collector**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete
> all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ►
> **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system
> meets all the required configurations, dependencies, and security measures necessary for a
> successful deployment.

**[Grafana][grafana], [InfluxDB][influxdb] and [Telegraf][telegraf] metrics collection for
[HashiCorp Nomad][hashicorp-nomad] clusters.**

The pack deploys **[Grafana][grafana]** for dashboards, **[InfluxDB][influxdb]** for metrics storage
and **[Telegraf][telegraf]** for scraping **[HashiCorp Nomad][hashicorp-nomad]** node metrics into a
`nomad` bucket. **[InfluxDB][influxdb]** stays internal with its UI disabled, while the
**[Grafana][grafana]** UI is exposed through **[Traefik][traefik]** at the configured hostname.

![Metrics dashboard](./assets/nomad-dashboard.png)

## Table of Contents

- [Compatibility & Requirements](#compatibility--requirements)
  - [Generic Requirements](#generic-requirements)
  - [Security Requirements](#security-requirements)
- [Configuration](#configuration)
  - [Pack Variables](#pack-variables)
  - [Example `vars.hcl`](#example-varshcl)
  - [Nomad Variables (Parameters)](#nomad-variables-parameters)
- [Pack Layout](#pack-layout)
- [Services & Ports](#services--ports)
- [Storage](#storage)
- [Contributing](#contributing)
- [License](#license)

## Compatibility & Requirements

### Generic Requirements

| Component      | Requirement / Note                     |
|----------------|----------------------------------------|
| Resources      | **CPU:** 925 MHz <br> **RAM:** 1040 MB |
| Namespace(s)   | `system`                               |
| Node class(es) | `main-worker`                          |
| CSI volumes    | ✅                                     |
| Ingress        | ✅                                     |

### Security Requirements

| Component  | Requirement / Note |
|------------|--------------------|
| Privileged | ❌                 |

## Configuration

### Pack Variables

| Variable   | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Default | Required | Description                                                                                       |
|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|----------|---------------------------------------------------------------------------------------------------|
| `hostname` | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |         | ✅       | The hostname (FQDN) used to access the **[Grafana][grafana]** monitoring UI.                      |
| `id`       | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |         | ✅       | Unique identifier used to distinguish multiple deployments of this pack with different variables. |
| `volumes`  | object({<br>&nbsp;&nbsp;db_data&nbsp;=&nbsp;object({<br>&nbsp;&nbsp;&nbsp;&nbsp;id&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=&nbsp;string<br>&nbsp;&nbsp;&nbsp;&nbsp;name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=&nbsp;string<br>&nbsp;&nbsp;&nbsp;&nbsp;plugin_id&nbsp;=&nbsp;string<br>&nbsp;&nbsp;})<br>&nbsp;&nbsp;ui_data&nbsp;=&nbsp;object({<br>&nbsp;&nbsp;&nbsp;&nbsp;id&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=&nbsp;string<br>&nbsp;&nbsp;&nbsp;&nbsp;name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=&nbsp;string<br>&nbsp;&nbsp;&nbsp;&nbsp;plugin_id&nbsp;=&nbsp;string<br>&nbsp;&nbsp;})<br>}) |         | ✅       | CSI volume configuration for persistent **[Grafana][grafana]** and **[InfluxDB][influxdb]** data. |

#### Example `vars.hcl`

```hcl
# The hostname (FQDN) used to access the Grafana monitoring UI.
hostname = "metrics.cluster.domain.com"

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"

# CSI volume configuration for persistent data.
volumes = {
  db_data = {
    id        = "metrics_collector-db_data"
    name      = "metrics_collector/db_data"
    plugin_id = "main"
  }

  ui_data = {
    id        = "metrics_collector-ui_data"
    name      = "metrics_collector/ui_data"
    plugin_id = "main"
  }
}
```

### Nomad Variables (Parameters)

| Job      | Variable  | Key                          | Default          | Description                                                                                                         |
|----------|-----------|------------------------------|------------------|---------------------------------------------------------------------------------------------------------------------|
| **self** | `config`  | `grafana.organization_name`  | `Cloud Skeleton` | Organization name configured in **[Grafana][grafana]**.                                                             |
| **self** | `config`  | `influxdb.data_retention`    | `604800`         | Retention period, in seconds, for the **[InfluxDB][influxdb]** `nomad` bucket.                                      |
| **self** | `config`  | `influxdb.nomad_nodes`       | `[]`             | JSON array of node names whose **[HashiCorp Nomad][hashicorp-nomad]** APIs are scraped by **[Telegraf][telegraf]**. |
| **self** | `config`  | `influxdb.organization_name` | `cloud-skeleton` | Organization name configured in **[InfluxDB][influxdb]**.                                                           |
| **self** | `images`  | `cleanstart/stunnel`         | `5.79`           | **[Docker][docker]** image tag for the ingress transport sidecar.                                                   |
| **self** | `images`  | `grafana/grafana`            | `13.1.1`         | **[Docker][docker]** image tag for **[Grafana][grafana]**.                                                          |
| **self** | `images`  | `influxdb`                   | `2.9.1-alpine`   | **[Docker][docker]** image tag for **[InfluxDB][influxdb]**.                                                        |
| **self** | `images`  | `telegraf`                   | `1.39.2-alpine`  | **[Docker][docker]** image tag for **[Telegraf][telegraf]**.                                                        |
| **self** | `secrets` | `grafana.admin_user`         |                  | Administrator username for **[Grafana][grafana]**.                                                                  |
| **self** | `secrets` | `grafana.admin_password`     |                  | Administrator password for **[Grafana][grafana]**.                                                                  |
| **self** | `secrets` | `influxdb.admin_user`        |                  | Administrator username for **[InfluxDB][influxdb]**.                                                                |
| **self** | `secrets` | `influxdb.admin_password`    |                  | Administrator password for **[InfluxDB][influxdb]**.                                                                |

## Pack Layout

```
packs/metrics_collector/
├─ assets/
│  └─ nomad-dashboard.png
├─ files/
│  ├─ grafana/
│  │  ├─ dashboards-provider.yml
│  │  ├─ grafana.ini
│  │  ├─ influxdb-datasource.yml.tpl
│  │  ├─ nomad-dashboard.json
│  │  └─ postconfig_grafana.sh
│  ├─ influxdb/
│  │  ├─ influxdb.yml.tpl
│  │  └─ postconfig_influxdb.sh
│  └─ telegraf/
│     └─ telegraf.conf.tpl
├─ metadata.hcl
├─ outputs.tpl
├─ README.md
├─ templates/
│  ├─ _vars.tpl
│  └─ self.nomad.tpl
├─ variables.hcl
└─ vars/
   └─ example.var.hcl
```

## Services & Ports

| Service Name                            | Port Name  | Host Port | Task Port | Description                                                                                      |
|-----------------------------------------|------------|-----------|-----------|--------------------------------------------------------------------------------------------------|
| `metrics-collector-self-http-${id}`     | `http`     | *dynamic* | `3000`    | **[Grafana][grafana]** web UI exposed through **[Traefik][traefik]** at the configured hostname. |
| `metrics-collector-self-influxdb-${id}` | `influxdb` | *dynamic* | `8086`    | **[InfluxDB][influxdb]** API.                                                                    |

## Storage

| Volume    | Access Mode               | Type              | Description                                                                 |
|-----------|---------------------------|-------------------|-----------------------------------------------------------------------------|
| `db_data` | `multi-node-multi-writer` | `csi file-system` | Persists **[InfluxDB][influxdb]** database data under `/var/lib/influxdb2`. |
| `ui_data` | `multi-node-multi-writer` | `csi file-system` | Persists **[Grafana][grafana]** application data under `/var/lib/grafana`.  |

## Contributing

Contributions and improvements to this installation script are welcome!  
- Fork the repository.  
- Create a new branch (e.g., **`feature/my-improvement`**).  
- Submit a pull request with your changes.

## License

This project is licensed under the [GNU General Public License v3.0](../../LICENSE).

---

*This repository is maintained exclusively by the **[Cloud Skeleton][cloud-skeleton]** project, and it
was developed by EU citizens who are strong proponents of the European Federation. 🇪🇺*

<!-- Reference -->
[cloud-skeleton]: https://github.com/cloud-skeleton/
[docker]: https://docs.docker.com/
[grafana]: https://grafana.com/docs/grafana/latest/
[hashicorp-nomad]: https://developer.hashicorp.com/nomad/tutorials/get-started
[hashicorp-nomad-packs]: https://developer.hashicorp.com/nomad/tools/nomad-pack
[influxdb]: https://docs.influxdata.com/influxdb/v2/
[packs-registry]: https://github.com/cloud-skeleton/packs-registry/
[prerequisites]: https://github.com/cloud-skeleton/prerequisites
[telegraf]: https://docs.influxdata.com/telegraf/v1/
[traefik]: https://doc.traefik.io/traefik/
