# Home Server K8S

## Overview

This repository was built to manage a (single-node) K3s Kubernetes cluster using a GitOps approach. The cluster is designed for high availability of home automation, media services, and infrastructure components, with all configurations managed via FluxCD.

### Server Requirements / Assumptions

- `k3s` installed on server ([Quick-Start Guide](https://docs.k3s.io/quick-start))

  - Should be run with `--disable=traefik` as the built-in Traefik installation lacks support for [Gateway API](https://gateway-api.sigs.k8s.io/). This can be done by adding the file `/etc/systemd/system/k3s.service.d/override.conf`, or using `systemctl edit k3s`:

    ```conf
    [Service]
    ExecStart= # "Clear" the default ExecStart
    ExecStart=/usr/local/bin/k3s server --disable=traefik
    ```

- The node should have a static IP assigned on the LAN, with a local DNS record for `travisprosser.ca` resolving to that IP.
  - This can be done with e.g. PiHole via `All Settings > misc.dnsmasq_lines`:
    ```
    address=/travisprosser.ca/<LAN IP>
    ```
    (Will require `Settings > Expert` to be enabled in the PiHole UI)

## Repository Structure and GitOps

The repository is organized as a [FluxCD monorepo](https://fluxcd.io/flux/guides/repository-structure/#monorepo) (though with only a single overlay, as only one cluster is ever expected to be used), separating core cluster logic, infrastructure components, and end-user applications.

```text
.
├── clusters/home-server      # Entry point for the cluster
│   ├── flux-system/          # FluxCD core components
│   ├── infrastructure.yaml   # Flux Kustomization resource for the infrastructure/ directory
│   └── apps.yaml             # Flux Kustomization resource for the apps/ directory
│
├── infrastructure/           # Cluster-wide services on which various workloads depend
│   ├── namespaces/           # Isolated namespace definition for components.
│   ├── traefik/              # Gateway API and Ingress Controller
│   ├── cert-manager/         # SSL/TLS certificate automation
│   ├── longhorn/             # Block storage and backup jobs
│   └── csi-driver-nfs/       # External NAS integration
│
└── apps/                     # Workload families
    ├── iot/                  # Automation (Home Assistant, Frigate, Zigbee)
    ├── media/                # Content (Sonarr, Radarr, Transmission)
    └── misc/                 # Utilities (Stirling-PDF, Strava tools, IT-Tools)
```

### FluxCD and Continuous Delivery

The repository follows a structured hierarchy to maintain clean separation of concerns, with three Flux Kustomizations defined:

- **flux-system**: Core Flux components and bootstrap manifests.
- **infrastructure**: Global components (Traefik, cert-manager, Longhorn).
- **apps**: Workloads organized by functional namespaces.

FluxCD defines a [Kustomization Custom Resource](https://fluxcd.io/flux/concepts/#kustomization) (not [to be confused with](https://fluxcd.io/flux/faq/#are-there-two-kustomization-types) the configuration for Kustomize Overlays) which describes which `kustomization.yaml` files to target when applying resources to the cluster. Each Flux Kustomization can be independently reconciled, suspended, etc, via the `flux` CLI ([docs](https://fluxcd.io/flux/cmd/)).

### Infrastructure Layer - The [`infrastructure/`](./infrastructure/) Directory

Includes various components such as:

- **Namespaces**: Every namespace is defined centrally in this directory
- **Storage**: Provided via Longhorn and NFS (`cis-driver-nfs`)
- **Certificate Management**: Provided via `cert-manager`
- **Ingress**: Provided via Traefik (with Gateway API)
- **Remote Access**: Provided via `cloudflared`

These are generally installed via FluxCD [HelmRepository](https://fluxcd.io/flux/components/source/helmrepositories/) and [HelmRelease](https://fluxcd.io/flux/guides/helmreleases/#using-a-chart-template) custom resources (the latter of which, define templates to create [HelmChart](https://fluxcd.io/flux/components/source/helmcharts/) resources).

### Application Layer - The [`apps/`](`./apps/`) Directory

Workloads are grouped by "families", which each have their own directory and corresponding namespace:

- `iot`: Apps pertaining to home automation or other devices in the smart home (e.g. cameras)
- `media`: Apps pertaining to media, such as downloaded movies, TV, books, and file sharing
- `misc`: Any other applications that do not fit within the above categories

Within each "family" directory, each application is defined within its own subdirectory, which typically contains the following common manifests/files (among others as needed):

- `deployment.yaml`: The core workload definition
- `service.yaml` & `httproute.yaml`: Networking definitions for internal and external access respectively
- `pvc.yaml`: Storage requests, generally backed by either longhorn or NFS
- `kustomization.yaml`: Orchestrates the local manifests and any necessary patches

> [!NOTE]
> The `apps` Kustomization defined in this directory depends on the `infrastructure` Kustomization as described above. This is because the latter provides a number of CRDs that are used by the former.

## Secrets Management

Sensitive data is stored in [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/), but is encrypted with [SOPS](https://github.com/getsops/sops) and [age](https://github.com/FiloSottile/age).

Flux provides [built-in support](https://fluxcd.io/flux/security/secrets-management/#using-flux-to-decrypt-secrets-on-demand) for decrypting these secrets on demand.

The SOPS configuration at [`.sops.yaml`](.sops.yaml) ensures that only `.yaml` files are considered for encryption/decryption by default, and only the `data`/`stringData` fields of any `v1/Secret` resource definition is actually encrypted within the file.

> [!NOTE]
> Each `kustomize.toolkit.fluxcd.io/v1.Kustomization` resource must define its own secrets decription within spec.decryption, e.g.:
>
> ```yaml
> spec:
>   ...
>   decryption:
>     provider: sops
>     secretRef:
>       name: sops-age
> ```

As a convention, unencrypted secrets should be written with the `.sops.yaml` extension to clearly indicate that they are in an unencrypted state, and will safely be ignored via a `.gitignore` rule. Encrypted secrets should be saved with the `.enc.yaml` extension to indicate they are safe to commit.

## Networking

### Traefik and Gateway API

The cluster uses the Kubernetes Gateway API for ingress management.

- **Manual Traefik Installation**: Traefik is installed as the Gateway provider to handle routing and TLS termination. See the Gateway configuration defined in the [`values.yaml`](infrastructure/traefik/values.yaml) referenced by the Traefik `HelmRelease` resource.
- **HTTPRoutes**: Routing is defined at the workload level, allowing individual applications to define their own hostnames without concern for TLS management.

### TLS Certificate Management

- **cert-manager**: Installed via a Helm Chart (see [`release.yaml`](infrastructure/cert-manager/release.yaml)). Manages the lifecycle of TLS certificates.
- **Let's Encrypt**: Configured with a `ClusterIssuer` using the Cloudflare DNS-01 challenge to support wildcard certificates (see [`cluster-issuer.yaml`](infrastructure/cert-manager/cluster-issuer.yaml)).
- **Wildcard Strategy**: Subdomains are handled via a wildcard secret (`*.travisprosser.ca`) attached to the Gateway listeners to simplify SNI matching.

### Remote Access

Though local/LAN access is prioritized, some applications may need to be accessed remotely. Generally this is to be done preferably with Tailscale, but where remote access is

- **Tailscale (Updates TBD)**: Planned in-cluster integration for a secure, peer-to-peer mesh VPN to allow broad administrative access to the cluster nodes.

  - Through the use of [Tailscale Subnet Routers](https://tailscale.com/kb/1019/subnets), the cluster can still be reached externally via other registered devices on the Tailnet. For a seamless experience, [configure the Tailnet to use PiHole as a nameserver](https://tailscale.com/kb/1114/pi-hole).

- **Cloudflared**: Exposes a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/), which is used for selective, zero-trust remote access to specific web-facing applications.
  - Managed via a deployment as per [Cloudflare docs](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/deployment-guides/kubernetes/#5-create-pods-for-cloudflared) (see [`deployment.yaml`](./infrastructure/cloudflared/deployment.yaml))
  - Some published tunnel routes may have specific access policies configured via [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/access-controls/policies/), which may enforce SSO login or other protections.
  - Tunnel is currently remotely managed via the [Cloudflare dashboard](https://dash.cloudflare.com/), but will be converted to a [locally managed tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/create-local-tunnel/) in the future to futher centralize configuration as IaC.

## Storage

Storage is managed primarily through dynamic provisioning via one of two `StorageClass` CRs, `longhorn` and `nfs-nas`.

### Longhorn

[Longhorn](https://longhorn.io/) provides distrubuted persistent storage within the cluster, with built-in snapshotting and deduplicated backup capabilities.

### NFS / NAS - Shared Bulk Media

[`csi-driver-nfs`](https://github.com/kubernetes-csi/csi-driver-nfs) provides a mechanism to mount external NFS shares (such as a NAS) into pods, primarily used for large-scale media libraries and shared data across namespaces.

See the values within the [`release.yaml`](infrastructure/csi-driver-nfs/release.yaml) file associated with the `csi-driver-nfs` Helm installation for details regarding how the `nfs-nas` `StorageClass` is configured (storage location, naming convention, etc.).

> [!NOTE]
> Existing directories on an NFS share can be mounted by manually defining a `PersistentVolume`, e.g. for existing downloaded media (see [`apps/media/nas-movies-pv.yaml`](apps/media/nas-movies-pv.yaml))

### Backups

Backups of Longhorn volumes are performed using Longhorn's recurring job framework as described [here](https://longhorn.io/docs/1.10.1/snapshots-and-backups/scheduling-backups-and-snapshots/).

The schedule is defined in this repo as `RecurringJob` resources for [nightly](infrastructure/longhorn/default-nightly-backup-recurringjob.yaml) and [weekly](infrastructure/longhorn/default-weekly-backup-recurringjob.yaml) backups.

As these jobs are targeting the `default` group, this is the backup/retention policy used for all volumes created through the `longhorn` `StorageClass`.

## GitOps and Continuous Delivery

### Kustomizations

- **Flux Kustomizations**: Separate reconciliation loops for apps, infrastructure, and the core system.
- **Kustomize Templating**: Extensive use of Kustomize for patching and environment-specific overrides.
  - _Note_: Specific `kustomizeconfig.yaml` is utilized for Frigate to handle complex custom resource definitions.

### Namespace Organization

Workloads are grouped into namespaces by "family":

- **iot**: Home Assistant, Zigbee2MQTT, and related automation.
- **media**: Processing and consumption tools like Stirling-PDF.
- **misc**: Miscellaneous apps and experimental workloads.
- **Component Namespaces**: Infrastructure is strictly isolated (e.g., `cert-manager`, `longhorn-system`, `csi-driver-nfs`).

## Updates and Maintenance

### Renovate

- **Automated Updates**: Renovate is configured to scan the repository for outdated Docker images, Helm charts, and GitHub Actions, automatically creating Pull Requests to keep the stack current.

> [!WARN]
> See [this link](https://docs.renovatebot.com/modules/manager/flux/#helmrelease-support:~:text=In%20addition%2C%20for%20the%20flux%20manager%20to%20properly%20link%20HelmRelease%20and%20HelmRepository%20resources%2C%20both%20of%20the%20following%20conditions%20must%20be%20met%3A) in the Renovate Docs for a "gotcha" regarding its ability to detect Flux's `HelmRelease` and `HelmRepository` dependencies.
>
> Though undocumented, it appears that so long as the `HelmRelease` and `HelmRepository` share a common `metadata.name`, this seems to satisfy the Renovate requirement and successfully associates the two resources.

## Helper Utilities and Patterns

### VS Code Sidecar Pattern

To facilitate direct editing of configuration files stored on Persistent Volumes:

- A `code-server` container is run as a sidecar within application pods. This allows for real-time YAML editing through a web-based VS Code interface.
- See the example used for Home Assistant in [`apps/iot/home-assistant/deployment.yaml`](apps/iot/home-assistant/deployment.yaml)
- (TODO) A globally shared configuration volume should be used to maintain consistent VS Code extensions and settings across different app editors.

### CronJobs

Any periodic jobs that should run can be scheduled via Kubernetes [`CronJob` resources](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

**Example**: The Statistics for Strava application requires periodic synchronization with the Strava API. See [`apps/misc/strava-statistics/import-and-build-cronjob.yaml`](apps/misc/strava-statistics/import-and-build-cronjob.yaml).

## Quick Reference / How To

### Flux Reconciliation

#### Suspending / Resuming

If changes are to be temporarily applied to the cluster "out of band", which would normally be overwrittend by typical Flux reconciliation, the associated Kustomization can be suspended via:

```bash
flux suspend kustomization <name>  # e.g. 'apps' or 'infrastructure'
```

While suspended, Flux will no longer periodically reconcile the state of the cluster against the state of the repo. To resume:

```bash
flux resume kustomization <name>
```

#### Adding new Kustomizations

To add a new Kustomization, add a manifest to the [cluster directory](./clusters/home-server/) which defines a resource of type `kustomize.toolkit.fluxcd.io/v1`. See [apps.yaml](./clusters/home-server/apps.yaml) for reference.

#### Forcing Reconciliation

Kustomizations are set to poll on a given interval, but in order to trigger off schedule, run:

```bash
flux reconcile kustomization <name>
```

> [!NOTE]
> Add `--with-source` flag to trigger a sync against the remote repository first.

### Secrets Management

#### Encrypting Secrets

Thanks to the `.sops.yaml` configuration in the root of this repository, one can encrypt a given secret with the default public key by running:

```bash
sops encrypt path/to/my-secret.sops.yaml > path/to/my-secret.enc.yaml
```

This encrypted file can be safely committed to git.

#### (Manually) Decrypting Secrets

For troubleshooting purposes, secrets can be decrypted using:

```bash
sops decrypt path/to/my-secret.enc.yaml > path/to/my-secret.sops.yaml
```

This requires possession of the secret key, stored in `$HOME/.config/sops/age/keys.txt` as described [here](https://github.com/getsops/sops?tab=readme-ov-file#23encrypting-using-age).

Note that secrets are stored unencrypted on the cluster, and so if the current values stored within a given `Secret` resource is desired, they can be printed with:

```bash
kubectl get secret <secret-name> -n <namespace> -o jsonpath='{.data.<keyName>}' | base64 --decode
```
