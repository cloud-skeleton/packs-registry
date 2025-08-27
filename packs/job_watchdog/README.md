![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **job_watchdog**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

**Nomad watchdog that auto-provisions variable access and defaults.**  
Automatically creates read/list ACL policies so job workloads can access variables under `/params/{job_name}`. It also inspects job metadata to pre-create Nomad Variables with sensible default values, reducing manual bootstrap and keeping configurations consistent.

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

| Component      | Requirement / Note                        |
|----------------|-------------------------------------------|
| Resources      | **CPU:** 50 MHz <br> **RAM:** 32 MB       |
| Namespace(s)   | `system`                                  |
| Node class(es) | `main-worker`                             |
| CSI volumes    | ❌                                        |
| Ingress        | ❌                                        |
| Variables      | `system/tools/nomad-job-watchdog/secrets` |

### Security Requirements

| Component          | Requirement / Note |
|--------------------|--------------------|
| Privileged         | ❌                 |
| Extra capabilities | ❌                 |

## Configuration

### Pack Variables

<!-- BEGIN_AUTO:VARIABLES_TABLE -->
| Variable               | Type     | Default      | Required | Description                                                                                                    |
|------------------------|----------|--------------|----------|----------------------------------------------------------------------------------------------------------------|
| `defaults_meta_prefix` | *string* | `"defaults"` | ❌       | Metadata prefix to be used as parameter defaults.                                                              |
| `id`                   | *string* |              | ✅       | Unique identifier used to distinguish multiple deployments of this pack with different variables.              |
| `parameters_root_path` | *string* | `"params"`   | ❌       | Root Nomad variables path that the watchdog manages (e.g., params/...).                                        |
| `watchdog_version`     | *string* | `"1.0"`      | ❌       | Container image version tag for job watchdog (maps to `ghcr.io/cloud-skeleton/nomad-job-watchdog:v<version>`). |
<!-- END_AUTO:VARIABLES_TABLE -->

### Example `vars.hcl`

```hcl
# Metadata prefix to be used as parameter defaults.
defaults_meta_prefix = "defaults"

# Unique identifier used to distinguish multiple deployments of this pack.
id = "<REQUIRED>"

# Root Nomad variables path that the watchdog manages (e.g., params/...).
parameters_root_path = "params"

# Container image version tag for job watchdog (maps to `ghcr.io/cloud-skeleton/nomad-job-watchdog:v<version>`).
watchdog_version = "1.0"
```

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

<!-- BEGIN_AUTO:SERVICES_TABLE -->
| Service Name | Port Var / Static | Target (in-task) | Ingress | Notes |
|--------------|-------------------|------------------|---------|-------|
<!-- END_AUTO:SERVICES_TABLE -->

## Storage

<!-- BEGIN_AUTO:VOLUMES_TABLE -->
| Volume ID | Mount Path | Access Mode | Attachment Mode | Notes |
|-----------|------------|-------------|-----------------|-------|
<!-- END_AUTO:VOLUMES_TABLE -->

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
