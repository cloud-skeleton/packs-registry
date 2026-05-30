![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **metrics_collector**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

**[Grafana][grafana]**, **[InfluxDB][influxdb]** and **[Telegraf][telegraf]** metrics collector for **[Nomad][hashicorp-nomad]** clusters.  
A compact monitoring stack that uses **[Telegraf][telegraf]** to collect metrics from **[Nomad][hashicorp-nomad]** nodes, stores them in **[InfluxDB][influxdb]**, and exposes dashboards through **[Grafana][grafana]**. **[Grafana][grafana]** is published through the **[Traefik][traefik]** reverse proxy using the internal mTLS tunnel, while **[InfluxDB][influxdb]** remains an internal service used by **[Grafana][grafana]** and **[Telegraf][telegraf]**.

## Table of Contents

- [Compatibility & Requirements](#compatibility--requirements)
  - [Generic Requirements](#generic-requirements)
  - [Security Requirements](#security-requirements)
- [Configuration](#configuration)
  - [Pack Variables](#pack-variables)
  - [Example `vars.hcl`](#example-varshcl)
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

| Variable         | Type                                                                                                       | Default | Required | Description                                                                                           |
|------------------|------------------------------------------------------------------------------------------------------------|---------|----------|-------------------------------------------------------------------------------------------------------|
| `db_data_volume` | object({<br>&nbsp;&nbsp;id = string,<br>&nbsp;&nbsp;name = string,<br>&nbsp;&nbsp;plugin_id = string<br>}) |         | ✅       | CSI volume configuration for persistent **[InfluxDB][influxdb]** data (ingester files, WAL, indexes). |
| `hostname`       | string                                                                                                     |         | ✅       | The hostname (FQDN) used to access the **[Grafana][grafana]** monitoring UI.                          |
| `id`             | string                                                                                                     |         | ✅       | Unique identifier used to distinguish multiple deployments of this pack with different variables.     |
| `ui_data_volume` | object({<br>&nbsp;&nbsp;id = string,<br>&nbsp;&nbsp;name = string,<br>&nbsp;&nbsp;plugin_id = string<br>}) |         | ✅       | CSI volume configuration for persistent **[Grafana][grafana]** data.                                  |

#### Example `vars.hcl`

```hcl
# CSI volume configuration for persistent InfluxDB data (ingester files, WAL, indexes).
db_data_volume = {
  id        = "metrics_collector-db_data"
  name      = "metrics_collector/db_data"
  plugin_id = "main"
}

# The hostname (FQDN) used to access the Grafana monitoring UI.
hostname = "metrics.cluster.domain.com"

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"

# CSI volume configuration for persistent Grafana data.
ui_data_volume = {
  id        = "metrics_collector-ui_data"
  name      = "metrics_collector/ui_data"
  plugin_id = "main"
}
```

### Nomad Variables (Parameters)

| Job          | Variable  | Key                          | Default          | Description                                                                                                                                    |
|--------------|-----------|------------------------------|------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| **ingester** | `config`  | `influxdb.data_retention`    | `604800`         | Retention period, in seconds, for the **[InfluxDB][influxdb]** `nomad` bucket. Default is 7 days.                                              |
| **ingester** | `config`  | `influxdb.nomad_nodes`       | `[]`             | JSON array of **[Nomad][hashicorp-nomad]** node DNS names or IP addresses that **[Telegraf][telegraf]** will scrape over HTTPS on port `4646`. |
| **ingester** | `config`  | `influxdb.organization_name` | `cloud-skeleton` | **[InfluxDB][influxdb]** organization name used for the `nomad` bucket and generated service tokens.                                           |
| **ingester** | `images`  | `cleanstart/stunnel`         | `5.77`           | Container image tag for the mTLS tunnel sidecar used by **[Grafana][grafana]**.                                                                |
| **ingester** | `images`  | `grafana/grafana`            | `13.0.1`         | Container image tag for **[Grafana][grafana]**.                                                                                                |
| **ingester** | `images`  | `influxdb`                   | `2.9.1-alpine`   | Container image tag for **[InfluxDB][influxdb]**.                                                                                              |
| **ingester** | `images`  | `telegraf`                   | `1.38.4-alpine`  | Container image tag for **[Telegraf][telegraf]**.                                                                                              |
| **ingester** | `secrets` | `grafana.admin_user`         |                  | **[Grafana][grafana]** administrator username.                                                                                                 |
| **ingester** | `secrets` | `grafana.admin_password`     |                  | **[Grafana][grafana]** administrator password.                                                                                                 |
| **ingester** | `secrets` | `influxdb.admin_user`        |                  | **[InfluxDB][influxdb]** administrator username.                                                                                               |
| **ingester** | `secrets` | `influxdb.admin_password`    |                  | **[InfluxDB][influxdb]** administrator password.                                                                                               |

## Pack Layout

```
packs/metrics_collector/
├─ files/
│  ├─ grafana.ini
│  ├─ nomad.json
│  ├─ postconfig_grafana.sh
│  └─ postconfig_influxdb.sh
├─ metadata.hcl
├─ outputs.tpl
├─ README.md
├─ templates/
│  ├─ ingester.nomad.tpl
│  └─ _vars.tpl
├─ variables.hcl
└─ vars/
   └─ example.var.hcl
```

## Services & Ports

| Service Name                                | Port Name  | Host Port | Task Port | Description                                                                                             |
|---------------------------------------------|------------|-----------|-----------|---------------------------------------------------------------------------------------------------------|
| `metrics-collector-ingester-http-${id}`     | `http`     | *dynamic* | `443`     | **[Grafana][grafana]** HTTPS endpoint exposed through the mTLS tunnel and reverse proxy.                |
| `metrics-collector-ingester-influxdb-${id}` | `influxdb` | *dynamic* | `8086`    | Internal **[InfluxDB][influxdb]** HTTP API used by **[Grafana][grafana]** and **[Telegraf][telegraf]**. |

## Storage

| Volume Name                 | Access Mode | Type | Description                                                               |
|-----------------------------|-------------|------|---------------------------------------------------------------------------|
| `metrics_collector/ui_data` | Read-write  | CSI  | Persistent **[Grafana][grafana]** data.                                   |
| `metrics_collector/db_data` | Read-write  | CSI  | Persistent **[InfluxDB][influxdb]** data, metadata, WAL and engine files. |

## Contributing

Contributions and improvements to this installation script are welcome!  
- Fork the repository.  
- Create a new branch (e.g., **`feature/my-improvement`**).  
- Submit a pull request with your changes.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

---

*This repository is maintained exclusively by the **[Cloud Skeleton][cloud-skeleton]** project, and it was developed by EU citizens who are strong proponents of the European Federation. 🇪🇺*

<!-- Reference -->
[cloud-skeleton]: https://github.com/cloud-skeleton/
[grafana]: https://grafana.com/docs/grafana/latest/
[hashicorp-nomad]: https://developer.hashicorp.com/nomad/tutorials/get-started
[hashicorp-nomad-packs]: https://developer.hashicorp.com/nomad/tools/nomad-pack
[influxdb]: https://docs.influxdata.com/influxdb/v2/
[packs-registry]: https://github.com/cloud-skeleton/packs-registry/
[prerequisites]: https://github.com/cloud-skeleton/prerequisites
[telegraf]: https://docs.influxdata.com/telegraf/
[traefik]: https://doc.traefik.io/traefik/