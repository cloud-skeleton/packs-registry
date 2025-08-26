![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **{{PACK_HANDLE}}**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ► **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system meets all the required configurations, dependencies, and security measures necessary for a successful deployment.

{{PACK_SUMMARY}}

## Table of Contents

- [Compatibility & Requirements](#compatibility--requirements)
- [Configuration](#configuration)
  - [Variables](#variables)
  - [Example `vars.hcl`](#example-varshcl)
- [Pack Layout](#pack-layout)
- [Services & Ports](#services--ports)
- [Storage](#storage)
- [Networking](#networking)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## Compatibility & Requirements

| Component       | Requirement / Note                             |
|----------------|-------------------------------------------------|
| Namespace(s)   | {{NAMESPACES_LIST}}                             |
| Network mode   | {{NETWORK_MODE}}                                |
| Traefik labels | {{TRAEFIK_ENABLED}}                             |
| CSI volumes    | {{CSI_ENABLED}}                                 |
| Resources      | **{{TOTAL_CPU_MHZ}} MHz / {{TOTAL_MEM_MB}} MB** |
| Constraints    | {{NODE_CONSTRAINTS}}                            |

## Configuration

### Variables

<!-- BEGIN_AUTO:VARIABLES_TABLE -->
| Variable                | Type                    | Default                    | Required                    | Description                    |
|-------------------------|-------------------------|----------------------------|-----------------------------|--------------------------------|
| {{VARIABLE_ROW_1_NAME}} | {{VARIABLE_ROW_1_TYPE}} | {{VARIABLE_ROW_1_DEFAULT}} | {{VARIABLE_ROW_1_REQUIRED}} | {{VARIABLE_ROW_1_DESCRIPTION}} |
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
| Service Name           | Port Var / Static      | Target (in-task)         | Ingress                   | Notes                   |
|------------------------|------------------------|--------------------------|---------------------------|-------------------------|
| {{SERVICE_ROW_1_NAME}} | {{SERVICE_ROW_1_PORT}} | {{SERVICE_ROW_1_TARGET}} | {{SERVICE_ROW_1_INGRESS}} | {{SERVICE_ROW_1_NOTES}} |
<!-- END_AUTO:SERVICES_TABLE -->

## Storage

<!-- BEGIN_AUTO:VOLUMES_TABLE -->
| Volume ID       | Mount Path         | Access Mode              | Attachment Mode          | Notes              |
|-----------------|--------------------|--------------------------|--------------------------|--------------------|
| {{VOLUME_1_ID}} | {{VOLUME_1_MOUNT}} | {{VOLUME_1_ACCESS_MODE}} | {{VOLUME_1_ATTACH_MODE}} | {{VOLUME_1_NOTES}} |
<!-- END_AUTO:VOLUMES_TABLE -->

## Networking

- **Mode:** {{NETWORK_MODE}}
- **host_network (if used):** {{HOST_NETWORK}}
- **Ingress (Traefik):** entrypoints={{TRAEFIK_ENTRYPOINTS}}; rule={{TRAEFIK_RULE}}; tls={{TRAEFIK_TLS}}
- **Public FQDN(s):** {{INGRESS_FQDNS}}

## Security

- **Secrets:** namespace=`{{SECRETS_NAMESPACE}}`; path_prefix=`{{NOMAD_VAR_PREFIX}}`; keys={{SECRET_KEYS_LIST}}; inject={{SECRETS_INJECTION}}
- **TLS:** enabled={{TLS_ENABLED}}; termination=`{{TLS_TERMINATION}}`; certs=`{{TLS_CERTS_SOURCE}}`; trust=`{{TLS_TRUST_STORE}}`; acme_resolver=`{{TLS_ACME_RESOLVER}}`
- **Privileges/Caps:** privileged={{PRIVILEGED}}; caps_add={{CAPS_ADD_LIST}}; run_as_user=`{{RUN_AS_USER}}`; read_only_rootfs={{READ_ONLY_ROOTFS}}; seccomp=`{{SECCOMP_PROFILE}}`; selinux=`{{SELINUX_LABEL}}`
- **Constraints:** {{SECURITY_CONSTRAINTS}}

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
