![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **{{PACK_HANDLE}}**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

{{PACK_SUMMARY}}

<!-- If the pack contains assets intended for README display, add them immediately after the overview text and before the Table of Contents. Example: ![Description](./assets/image.png) -->
{{PACK_ASSETS}}

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

<!-- Keep Markdown table columns padded to the longest cell for source readability. Pad icon/emoji cells by visual column width so table pipes stay aligned in source. -->
| Component      | Requirement / Note      |
|----------------|-------------------------|
| Resources      | **CPU:** {{TOTAL_CPU_MHZ}} MHz <br> **RAM:** {{TOTAL_MEM_MB}} MB |
| Namespace(s)   | {{NAMESPACES_LIST}}     |
| Node class(es) | {{NODE_CLASSES}}        |
| CSI volumes    | {{CSI_ENABLED}}         |
| Ingress        | {{INGRESS_DESC}}        |

### Security Requirements

<!-- Keep Markdown table columns padded to the longest cell for source readability. Pad icon/emoji cells by visual column width so table pipes stay aligned in source. -->
| Component  | Requirement / Note |
|------------|--------------------|
| Privileged | {{PRIVILEGED}}     |

## Configuration

### Pack Variables

<!-- BEGIN_AUTO:VARIABLES_TABLE -->
<!-- Keep generated Markdown table columns padded to the longest cell for source readability. For nested object types, use <br> with &nbsp; padding so attribute names and equals signs stay aligned inside the Type cell. Pad icon/emoji cells by visual column width so table pipes stay aligned in source. -->
| Variable  | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| {{VAR_1}} | ...  | ...     | ...      | ...         |
<!-- END_AUTO:VARIABLES_TABLE -->

#### Example `vars.hcl`

```hcl
{{EXAMPLE_VARS_HCL}}
```

### Nomad Variables (Parameters)

<!-- BEGIN_AUTO:NOMAD_VARIABLES_TABLE -->
<!-- Keep generated Markdown table columns padded to the longest cell for source readability. Pad icon/emoji cells by visual column width so table pipes stay aligned in source. -->
| Job      | Variable | Key       | Default | Description |
|----------|----------|-----------|---------|-------------|
| **self** | `config` | `{{KEY}}` | `...`   | ...         |
<!-- END_AUTO:NOMAD_VARIABLES_TABLE -->

## Pack Layout

```
packs/{{PACK_HANDLE}}/
├─ files/
│  ├─ {{FILE_1}}
│  └─ {{FILE_N}}
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
<!-- Keep generated Markdown table columns padded to the longest cell for source readability. Pad icon/emoji cells by visual column width so table pipes stay aligned in source. -->
| Service Name  | Port Name | Host Port | Task Port | Description |
|---------------|-----------|-----------|-----------|-------------|
| {{SERVICE_1}} | `...`     | *dynamic* | `...`     | ...         |
<!-- END_AUTO:SERVICES_TABLE -->

## Storage

<!-- BEGIN_AUTO:VOLUMES_TABLE -->
<!-- Keep generated Markdown table columns padded to the longest cell for source readability. Pad icon/emoji cells by visual column width so table pipes stay aligned in source. -->
| Volume    | Access Mode | Type | Description |
|-----------|-------------|------|-------------|
| `{{VOL}}` | Read-write  | CSI  | ...         |
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
