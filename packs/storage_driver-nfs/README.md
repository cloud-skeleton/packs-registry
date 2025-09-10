![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **storage_driver-nfs**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

**NFS CSI storage driver.**  
A lightweight, stateless CSI plugin that mounts directories from an **existing NFS export** and exposes them to workloads as filesystem volumes. It’s orchestrator-agnostic but tuned for **HashiCorp Nomad**; the driver avoids any external state store and creates **per-volume subdirectories** under a single NFS share (block devices are not supported).

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
| Resources      | **CPU:** 100 MHz <br> **RAM:** 128 MB     |
| Namespace(s)   | `system`                                  |
| Node class(es) | `ingress-worker`, `main-worker`           |
| CSI volumes    | ❌                                        |
| Ingress        | ❌                                        |

### Security Requirements

| Component          | Requirement / Note |
|--------------------|--------------------|
| Privileged         | ✅                 |
| Extra capabilities | ❌                 |

## Configuration

### Pack Variables

| Variable | Type     | Default | Required | Description                                                                                       |
|----------|----------|---------|----------|---------------------------------------------------------------------------------------------------|
| `id`     | *string* |         | ✅       | Unique identifier used to distinguish multiple deployments of this pack with different variables. |

#### Example `vars.hcl`

```hcl
# Unique identifier used to distinguish multiple deployments of this pack.
id = "main"
```

### Nomad Variables (Parameters)

| Variable                 | Key                                             | Default | Description                                                                                 |
|--------------------------|-------------------------------------------------|---------|---------------------------------------------------------------------------------------------|
| `csi_plugin` ➢ `config`  | `log_level`                                     | "INFO"  | Log verbosity for the CSI plugin. Allowed: `CRITICAL`, `ERROR`, `WARNING`, `INFO`, `DEBUG`. |
| `csi_plugin` ➢ `images`  | `registry.gitlab.com/rocketduck/csi-plugin-nfs` | "1.1.0" | Container image tag for the CSI plugin.                                                     |
| `csi_plugin` ➢ `secrets` | `nfs_share`                                     |         | NFS export in `<server>:/<path>` format, e.g., `nas.lan:/export/nomad`.                     |

## Pack Layout

```
packs/job_watchdog/
├─ metadata.hcl
├─ outputs.tpl
├─ README.md
├─ templates/
│  ├─ csi_plugin.nomad.tpl
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
