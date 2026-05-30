![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **job_watchdog**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

**Nomad watchdog that auto-provisions variable access, parameter defaults and volumes.**  
Automatically creates read/list ACL policies so job workloads can access variables under `/params/{job_name}`. It also inspects job metadata to pre-create Nomad Variables and initialize volumes, reducing manual bootstrap and keeping configurations consistent. Finally it also includes automated Docker image tag updating mechanism and certificates rotation.

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

| Component      | Requirement / Note                  |
|----------------|-------------------------------------|
| Resources      | **CPU:** 50 MHz <br> **RAM:** 32 MB |
| Namespace(s)   | `system`                            |
| Node class(es) | `main-worker`                       |
| CSI volumes    | ❌                                  |
| Ingress        | ❌                                  |

### Security Requirements

| Component  | Requirement / Note |
|------------|--------------------|
| Privileged | ❌                 |

## Configuration

### Pack Variables

| Variable           | Type                                           | Default                               | Required | Description                                                                                                                                                                                                               |
|--------------------|------------------------------------------------|---------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `autoupdater_cron` | *object({ cron = string, timezone = string })* | { cron = "@daily", timezone = "UTC" } | ❌       | Schedule for the autoupdater periodic job. `cron` accepts standard CRON expressions or nicknames (e.g., @hourly, @daily), and `timezone` is the IANA time zone (e.g., UTC, Europe/Vilnius) used to evaluate the schedule. |
| `id`               | *string*                                       |                                       | ✅       | Unique identifier used to distinguish multiple deployments of this pack with different variables.                                                                                                                         |

#### Example `vars.hcl`

```hcl
# Schedule for the autoupdater periodic job. `cron` accepts standard CRON expressions or nicknames (e.g., @hourly, @daily), and `timezone` is the IANA time zone (e.g., UTC, Europe/Vilnius) used to evaluate the schedule.
autoupdater_cron = {
    cron     = "@daily"
    timezone = "UTC"
}

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"
```

### Nomad Variables (Parameters)

| Job             | Variable | Key                                                     | Default                                                                            | Description                                                                                               |
|-----------------|----------|---------------------------------------------------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| **autoupdater** |`config`  | `certificates_root_path`                                | "certs"                                                                            | Base path in Nomad Variables (KV) that the **autoupdater** manages for certificates (e.g., `certs/`).     |
| **autoupdater** |`config`  | `images_variable_name`                                  | "images"                                                                           | Name of the Nomad Variable (under `parameters_root_path`) that stores the map of Docker images.           |
| **autoupdater** |`config`  | `ingress_worker_ips`                                    | "[]"                                                                               | JSON array of IPs for **ingress (Traefik) nodes**; used to add IP SANs to the **ingress (client)** cert. |
| **autoupdater** |`config`  | `main_worker_ips`                                       | "[]"                                                                               | JSON array of IPs for **main/worker nodes**; used to add IP SANs to the **main (server)** cert.     |
| **autoupdater** |`config`  | `parameters_root_path`                                  | "params"                                                                           | Base path in Nomad Variables (KV) that the **autoupdater** manages (e.g., `params/`).                     |
| **autoupdater** |`config`  | `version_update_lock`                                   | {"major": true, "minor": false, "patch": false, "prerelease": true, "build": true} | Map of booleans controlling updates; **true** = do **not** update that SemVer component.                  |
| **autoupdater** |`images`  | `ghcr.io/cloud-skeleton/nomad-job-watchdog-autoupdater` | "v1.2.1"                                                                           | Container image **tag** for the job watchdog autoupdater (key is the full repository name).               |
| **watcher**     |`config`  | `parameters_meta_prefix`                                | "params"                                                                           | Prefix for job meta keys that hold default parameter values.                                              |
| **watcher**     |`config`  | `parameters_root_path`                                  | "params"                                                                           | Base path in Nomad Variables (KV) that the **watcher** manages (e.g., `params/`).                         |
| **watcher**     |`config`  | `volumes_meta_prefix`                                   | "volumes"                                                                          | Prefix for job meta keys used for **volume** configuration.                                               |
| **watcher**     |`images`  | `ghcr.io/cloud-skeleton/nomad-job-watchdog`             | "v1.5.2"                                                                           | Container image **tag** for the job watchdog (key is the full repository name).                           |
| **watcher**     |`secrets` | `nomad_token`                                           |                                                                                    | Nomad management token used by the watcher to list/update variables and volumes.                          |

## Pack Layout

```
packs/job_watchdog/
├─ metadata.hcl
├─ outputs.tpl
├─ README.md
├─ templates/
│  ├─ watcher.nomad.tpl
│  └─ _vars.tpl
├─ variables.hcl
└─ vars/
   └─ example.var.hcl
```

## Services & Ports

| Service Name | Port Name | Source Port | Destination Port | Description |
|--------------|-----------|-------------|------------------|-------------|

## Storage

| Mount Path | Access Mode | Type | Description |
|------------|-------------|------|-------------|

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
[hashicorp-nomad]: https://developer.hashicorp.com/nomad/tutorials/get-started
[hashicorp-nomad-packs]: https://developer.hashicorp.com/nomad/tools/nomad-pack
[packs-registry]: https://github.com/cloud-skeleton/packs-registry/
[prerequisites]: https://github.com/cloud-skeleton/prerequisites
