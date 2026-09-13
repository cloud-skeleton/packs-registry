<!--
README generation notes:
- Generate from the current pack files only: metadata.hcl, variables.hcl, vars/example.var.hcl,
  templates/*.tpl, files/* and tracked assets.
- Keep every non-table source line at 120 characters or fewer in this template and in generated
  pack README files. Markdown table rows are the only exception: table padding takes precedence over
  the 120-character limit.
- Prefer precise, pack-specific wording over generic summaries. Every mention of a specific
  application, platform, product, tool, project, or Cloud Skeleton repository must be a bold
  reference link to its documentation or repository on every occurrence, including repeated
  mentions in prose, requirements, variable descriptions, services and storage. Do not create
  reference links for generic protocols, formats, storage concepts, or acronyms such as SSH,
  TLS, mTLS, CSI, JSON, HTTP, HTTPS, TCP, file-system, ingress, proxy, sidecar, bucket,
  database, or API unless they are part of a specific product name. Use `**[Name][reference]**`
  unless the surrounding text is already bold; inside already-bold text, use `[Name][reference]`.
- Use `templates/ref.md` as the canonical reference registry. Before adding any reference link to a
  generated README, search `templates/ref.md` for an existing matching key and reuse that exact key
  and URL so links stay consistent across packs. If a needed product/tool/project reference is
  missing, add it to `templates/ref.md` first with a documentation URL when available, then copy that
  same reference definition into the generated README. Include only references actually used by that
  README, and before finishing generation verify that every bracket reference has a matching entry in
  the Reference section.
- Avoid implementation-only phrasing such as "applied during post-configuration" unless the
  timing is user-visible configuration behavior. Keep internal Cloud Skeleton transport/proxy
  implementation details out of the overview, including stunnel, mTLS tunnels, sidecar proxy
  tools, and other replaceable ingress plumbing, unless the user configures that component
  directly. If the pack has Traefik labels, say it is exposed through **[Traefik][traefik]**; do
  not add generic fallback wording such as "or the configured reverse proxy".
- Pad Markdown tables only after all final content is known; table rows may exceed 120 characters.
  A cell is the text between two pipes. For each column, find the maximum trimmed width among its
  final header and body cells, using literal Markdown source: markup, `<br>`, and `&nbsp;` count.
  Treat `✅` and `❌` as visual width 2. Set the separator to exactly that maximum plus 2 hyphens.
  Then give every content cell exactly one leading space, its content, and only enough right padding
  for its segment to match the separator. This is exact, never a minimum: no fixed widths, margins,
  placeholder widths, safety padding, or retained outer whitespace are allowed. Before finishing,
  reject and repad any column whose separator is not exactly `max(final_cell_widths) + 2`; every
  pipe in that column must align visually. Do not size columns from rendered text, examples,
  pre-link text, or a first row. Re-read the Markdown source and fix any non-table line over 120
  characters.
- Do not copy template comments, BEGIN_AUTO/END_AUTO markers, or unresolved {{PLACEHOLDERS}} into
  generated pack README files.
- Preserve fixed template text exactly, including the prerequisite warning block.
- For yes/no requirement values, use `✅` or `❌` as the primary value. Add a short explanation
  after the emoji only when the detail is useful.
-->
![Cloud Skeleton](../../assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](../../LICENSE)
[![Tool: Nomad Pack](https://img.shields.io/badge/Tool-Nomad_Pack-green)]()
<!--
Add an Apps badge directly after the Nomad Pack badge. Derive its application names from the pack's
primary workload tasks, preserving their user-facing product names and deployment order. Exclude
implementation-only tasks and sidecars, including tunnels, proxies, post-configuration tasks, and
other replaceable Cloud Skeleton plumbing. Use the exact format below: comma-and-space separators in
the alt text and comma-underscore separators in the Shields URL. For example, Grafana, InfluxDB and
Telegraf render as `[![Apps: Grafana, InfluxDB, Telegraf](https://img.shields.io/badge/Apps-
Grafana,_InfluxDB,_Telegraf-violet)]()`.
-->
{{APPS_BADGE}}

# **[Cloud Skeleton][cloud-skeleton]** ► **[Packs Registry][packs-registry]**  ► **{{PACK_HANDLE}}**

## Overview

> **IMPORTANT:** Before deploying any **[Nomad Packs][hashicorp-nomad-packs]**, **you must complete
> all the prerequisites detailed in the **[Cloud Skeleton][cloud-skeleton]** ►
> **[Prerequisites][prerequisites]** repository.** This step is essential to ensure that your system
> meets all the required configurations, dependencies, and security measures necessary for a
> successful deployment.

<!--
Start with one short bold sentence naming only user-facing pack technologies and purpose. Link every
specific product/tool/platform/project name in this sentence, including the target platform. Because
this sentence is already bold, use `[Name][reference]` inside it instead of nested bold markup. Add a
blank line after that bold sentence, then one compact paragraph describing what the pack deploys,
what stays internal, and what is exposed through ingress. When Traefik labels are present, say the
service is exposed through **[Traefik][traefik]**; do not add generic fallback wording such as "or the
configured reverse proxy". Do not mention mTLS, tunnel sidecars, or concrete proxy tools in the
overview unless directly user-configurable. Link every specific product/tool/platform/project name in
the paragraph too, using `**[Name][reference]**` because the paragraph is not already bold.
-->
{{PACK_SUMMARY}}

<!--
If the pack contains README-display assets under assets/, add them immediately after the overview text
and before the Table of Contents. Use descriptive alt text, e.g.
![Nomad dashboard](./assets/nomad-dashboard.png). Leave empty if no README assets exist.
-->
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

<!--
For binary capability rows such as CSI volumes and Ingress, use only `✅` or `❌` in this table; keep
generic component labels such as CSI volumes plain, without reference links. Put detailed volume
names, ingress routing, proxy, or transport information in Storage or Services sections instead.
Render Resources as `**CPU:** X MHz <br> **RAM:** Y MB`, but size the column from final content.
Calculate CPU and RAM by summing every explicit `resources` block that can run concurrently in the
pack, including lifecycle and post-configuration tasks plus tasks expanded from shared templates or
symlinked template files. Do not omit sidecars or substitute rounded application-only estimates.
Render namespace and node class values as code-formatted literals, for example `system`.
-->
| Component      | Requirement / Note  |
|----------------|---------------------|
| Resources      | {{RESOURCES}}       |
| Namespace(s)   | {{NAMESPACES_LIST}} |
| Node class(es) | {{NODE_CLASSES}}    |
| CSI volumes    | {{CSI_ENABLED}}     |
| Ingress        | {{INGRESS_DESC}}    |

### Security Requirements

<!--
For binary security requirement rows such as Privileged, use only `✅` or `❌` in this table. Do not
append explanatory text for simple yes/no values; put any needed detail in a separate section instead.
-->
| Component  | Requirement / Note |
|------------|--------------------|
| Privileged | {{PRIVILEGED}}     |

## Configuration

### Pack Variables

<!-- BEGIN_AUTO:VARIABLES_TABLE -->
<!--
Use raw HCL type names such as string/object(...), not italicized types. Copy nested type delimiters
exactly from variables.hcl: `object({` must retain its opening `{`, and closing `})` must be present.
Preserve the source punctuation and line structure exactly; do not add optional commas, alter
separators, or otherwise normalize HCL formatting while converting lines to `<br>`.
Remove only the source indentation that precedes the type expression. Preserve all indentation inside
that expression exactly: a source member indented by two spaces after `object({` must use exactly two
`&nbsp;` entities, not four.
For nested object types, use <br> with &nbsp; padding so attribute names and equals signs stay aligned
inside the Type cell. Encode every indentation and alignment space as `&nbsp;`, including spaces
before and after `=`. Never use ordinary spaces for alignment because HTML collapses them. For
example, render `object({` as `object({<br>` rather than `object(<br>`, and render an assignment as
`&nbsp;&nbsp;db_data&nbsp;=&nbsp;object({`.
Calculate every table column independently. A wide Type value must not add padding to the Default,
Required, or Description columns; each uses only its own longest final cell plus two spaces.
-->
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
<!--
Include only user-facing `config`, `images` and `secrets` variables discovered in templates/_vars.tpl.
Do not document `state` variables because they are internal pack state. Descriptions should explain
what the value configures, not how scripts apply it. Use bold reference links for specific product/
tool/platform/project names in descriptions, such as Docker, Nomad, Grafana, InfluxDB, Telegraf and
Traefik, unless the cell text is already bold. Leave generic concepts such as CSI, TLS, mTLS, JSON,
HTTP and HTTPS unlinked. Do not add reference links for implementation-only sidecar products such as
stunnel; keep those image names literal and describe them generically, e.g. Docker image tag for the
ingress transport sidecar. Render non-empty Default values as code-formatted literals, for example
`604800`, `Cloud Skeleton` or `[]`. Leave the Default cell empty when no explicit default exists.
Preserve key order from templates/_vars.tpl.
-->
| Job      | Variable | Key       | Default | Description |
|----------|----------|-----------|---------|-------------|
| **self** | `config` | `{{KEY}}` | `...`   | ...         |
<!-- END_AUTO:NOMAD_VARIABLES_TABLE -->

## Pack Layout

<!--
Keep Pack Layout limited to tracked/distributable pack files, including symlinks. Omit
ignored/local-only files such as debug.var.hcl. A symlink in the pack directory is part of the pack:
list the symlink's own name at its location, even when its target is a shared template outside the
pack, for example `templates/_vars.tpl`. Sort entries alphabetically inside each directory. If
assets/ exists and should be documented, render it through {{ASSETS_LAYOUT}} directly under
packs/{{PACK_HANDLE}}/.
-->

```
packs/{{PACK_HANDLE}}/
{{ASSETS_LAYOUT}}
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
<!--
Describe whether each service is internal or ingress-facing. In the Task Port column, include only the
final application container port reached by the service, for example `3000`. For services fronted by a
tunnel, proxy, or sidecar, follow the upstream mapping and document the application port behind it,
not the tunnel listener, service listener, Nomad network `to` value, or ingress listener. Do not use
forwarding notation such as `443 -> 3000`. Put any useful forwarding or ingress details in the
Description column instead. If the service has Traefik labels, describe it as exposed through
**[Traefik][traefik]**; do not add generic fallback wording such as "or the configured reverse proxy".
Use plain wording such as "at the configured hostname" instead of inventing pack-variable
interpolation like `https://${hostname}`. For internal-only services, keep Description extremely
short and describe the port purpose, for example `**[InfluxDB][influxdb]** API.`; do not restate that
the service is internal or list other tasks that consume it unless that relationship is surprising.
Link every specific product/tool/platform/project name in descriptions as a bold reference link,
including Nomad, Traefik, Grafana, InfluxDB and Telegraf, unless the cell text is already bold. Leave
generic concepts such as TLS, mTLS, HTTP, HTTPS, ingress, proxy and sidecar unlinked. Preserve Nomad
interpolation syntax exactly, for example `${id}`, instead of replacing it with `<id>`. Do not invent
interpolation for pack variables in prose unless that exact string appears in the pack template.
In the Service Name column, render the actual value produced by each `service.name` expression, not
the task name or product name. When the shared `service_name` helper is used, preserve its generated
pattern and `${id}` interpolation exactly, for example `metrics-collector-self-http-${id}`.
-->
| Service Name  | Port Name | Host Port | Task Port | Description |
|---------------|-----------|-----------|-----------|-------------|
| {{SERVICE_1}} | `...`     | *dynamic* | `...`     | ...         |
<!-- END_AUTO:SERVICES_TABLE -->

## Storage

<!-- BEGIN_AUTO:VOLUMES_TABLE -->
<!--
Use pack-specific storage descriptions, including product names and what data is persisted. Link every
specific product/tool/platform/project name in descriptions as a bold reference link, including
storage products, databases and application names, unless the cell text is already bold. Leave generic
storage concepts such as CSI, file-system, bucket, volume, database and engine unlinked. Preserve
Nomad volume values exactly: use the job's `access_mode` value, and combine `type` plus
`attachment_mode` for Type, for example `csi file-system`.
In the Volume column, use the literal label declared by `volume "..."`, for example `db_data`, rather
than its `source` expression, pack variable path, or resolved variable value.
Sort volume rows alphanumerically by their literal Volume column labels.
-->
| Volume    | Access Mode | Type              | Description |
|-----------|-------------|-------------------|-------------|
| `{{VOL}}` | `...`       | `csi file-system` | ...         |
<!-- END_AUTO:VOLUMES_TABLE -->

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
[hashicorp-nomad]: https://developer.hashicorp.com/nomad/tutorials/get-started
[hashicorp-nomad-packs]: https://developer.hashicorp.com/nomad/tools/nomad-pack
[packs-registry]: https://github.com/cloud-skeleton/packs-registry/
[prerequisites]: https://github.com/cloud-skeleton/prerequisites
<!--
Reference entries in generated pack README files must be copied from `templates/ref.md`. If a
required product/tool/project reference is missing there, add it to `templates/ref.md` first, then use
the same key and URL here. Include only references used by the generated README, sorted
alphanumerically by reference key.
-->
