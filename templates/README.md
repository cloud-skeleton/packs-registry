![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **{{PACK_HANDLE}}**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

{{PACK_SUMMARY}}

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

| Component      | Requirement / Note      |
|----------------|-------------------------|
| Resources      | **CPU:** {{TOTAL_CPU_MHZ}} MHz <br> **RAM:** {{TOTAL_MEM_MB}} MB |
| Namespace(s)   | {{NAMESPACES_LIST}}     |
| Node class(es) | {{NODE_CLASSES}}        |
| CSI volumes    | {{CSI_ENABLED}}         |
| Ingress        | {{INGRESS_DESC}}        |
| Variables      | {{NOMAD_VAR_PATHS}}     |

### Security Requirements

| Component          | Requirement / Note |
|--------------------|--------------------|
| Privileged         | {{PRIVILEGED}}     |
| Extra capabilities | {{CAPS_ADD_LIST}}  |

## Configuration

### Pack Variables

<!-- BEGIN_AUTO:VARIABLES_TABLE -->
| Variable  | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| {{VAR_1}} | ...  | ...     | ...      | ...         |
<!-- END_AUTO:VARIABLES_TABLE -->

### Example `vars.hcl`

```hcl
# AUTO-GENERATED example based on pack defaults
{{EXAMPLE_VARS_HCL}}
```

## Pack Layout

```
packs/{{PACK_HANDLE}}/
├─ metadata.hcl
├─ outputs.tpl
├─ README.md
├─ templates/
│  ├─ {{JOBFILE_NAME}}.nomad.tpl
│  └─ {{ADDITIONAL_TPL_FILES}}
├─ variables.hcl
└─ vars/
   └─ example.var.hcl
```

## Services & Ports

<!-- BEGIN_AUTO:SERVICES_TABLE -->
| Service Name  | Port Var / Static | Target (in-task) | Ingress | Notes |
|---------------|-------------------|------------------|---------|-------|
| {{SERVICE_1}} | ...               | ...              | ...     | ...   |
<!-- END_AUTO:SERVICES_TABLE -->

## Storage

<!-- BEGIN_AUTO:VOLUMES_TABLE -->
| Volume ID    | Mount Path | Access Mode | Attachment Mode | Notes |
|--------------|------------|-------------|-----------------|-------|
| {{VOLUME_1}} | ...        | ...         | ...             | ...   |
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
