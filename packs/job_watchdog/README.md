![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **job_watchdog**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

**Nomad watchdog that auto-provisions variable access, parameter defaults and volumes.**  
Automatically creates read/list ACL policies so job workloads can access variables under `/params/{job_name}`. It also inspects job metadata to pre-create Nomad Variables and initialize volumes, reducing manual bootstrap and keeping configurations consistent.

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

| Variable | Type     | Default | Required | Description                                                                                       |
|----------|----------|---------|----------|---------------------------------------------------------------------------------------------------|
| `id`     | *string* |         | ✅       | Unique identifier used to distinguish multiple deployments of this pack with different variables. |

#### Example `vars.hcl`

```hcl
# Unique identifier used to distinguish multiple deployments of this pack.
id = "<REQUIRED>"
```

### Nomad Variables (Parameters)

| Variable  | Key                                         | Default  | Description                                                                  |
|-----------|---------------------------------------------|----------|------------------------------------------------------------------------------|
| `config`  | `parameters_meta_prefix`                    | "params" | Prefix for job meta keys holding default parameter values.                   |
| `config`  | `parameters_root_path`                      | "params" | Base path in Nomad Variables (KV) that the watchdog manages (e.g., params/). |
| `config`  | `volumes_meta_prefix`                       | "volumes"| Prefix for job meta keys used for **volume** configuration.                  |
| `images`  | `ghcr.io/cloud-skeleton/nomad-job-watchdog` | "v1.2"   | Container image tag for the job watchdog.                                    |
| `secrets` | `nomad_token`                               |          | Nomad management token used by the watchdog.                                 |

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

| Service Name | Port Var / Static | Target (in-task) | Ingress | Notes |
|--------------|-------------------|------------------|---------|-------|

## Storage

| Volume ID | Mount Path | Access Mode | Attachment Mode | Notes |
|-----------|------------|-------------|-----------------|-------|

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
