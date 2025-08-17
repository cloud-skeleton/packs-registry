![Cloud Skeleton](./assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Tool: Nomad](https://img.shields.io/badge/Tool-Nomad-green)]()

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**

## Overview

The **[Packs Registry][packs-registry]** repository provides a unified, interactive catalog of reusable **[Nomad Packs][hashicorp-nomad-packs]** for deploying and managing services on **[HashiCorp Nomad][hashicorp-nomad]**, tailored for the **[Cloud Skeleton][cloud-skeleton]** infrastructure via pack inputs, variables, and job templates.

## Usage

Follow these steps to discover, inspect, and deploy **[Nomad Packs][hashicorp-nomad-packs]** from the **[Packs Registry][packs-registry]**.

1. Configure access to your **[HashiCorp Nomad][hashicorp-nomad]** cluster:  

    Export the required environment variables

    ```bash
    export NOMAD_ADDR=https://<your_nomad_http_api_address>:<your_nomad_http_api_port>
    ```

    ```bash
    export NOMAD_TOKEN=<your_nomad_token>
    ```

    ```bash
    export NOMAD_CACERT=<your_nomad_ca_cert_path>
    ```

2. Install **[Nomad Pack][hashicorp-nomad-packs]**:  

    Install CLI for your platform and confirm it's installed

    ```bash
    nomad-pack version
    ```

3. Add the **[Packs Registry][packs-registry]**:  

    ```bash
    nomad-pack registry add default github.com/cloud-skeleton/packs-registry
    ```

4. Discover available packs:  

    ```bash
    nomad-pack list
    ```

5. Inspect a pack (inputs, templates, docs):  

    ```bash
    nomad-pack info <PACK_NAME>
    ```

    > **Tip:** Use `nomad-pack render <PACK_NAME> --var <name1>=<value1> --var <name2>=<value2>` to see the rendered **[HashiCorp Nomad][hashicorp-nomad]** jobs without deploying.

6. Deploy a **[Nomad Pack][hashicorp-nomad-packs]**:  

    Dry-run (plan)

    ```bash
    nomad-pack plan <PACK_NAME> \
        --var <name1>=<value1> \
        --var <name2>=<value2>
    ```

    Apply

    ```bash
    nomad-pack run <PACK_NAME> \
        --var <name1>=<value1> \
        --var <name2>=<value2>
    ```

7. Destroy a **[Nomad Pack][hashicorp-nomad-packs]**:  

    Apply

    ```bash
    nomad-pack destroy <PACK_NAME> \
        --var <name1>=<value1> \
        --var <name2>=<value2>
    ```

---

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
