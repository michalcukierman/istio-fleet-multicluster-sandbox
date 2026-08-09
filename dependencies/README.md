# StreamX Sandbox Dependencies

Development dependencies deployed into the StreamX multicluster sandbox using Rancher Fleet.

## Components

- Envoy Gateway on `edge` and `processing`
- Apache Pulsar standalone on `pilot`
- RustFS standalone on `pilot`

```text
dependencies/
├── envoy-gateway/
│   └── fleet.yaml
├── pulsar/
│   ├── fleet.yaml
│   └── pulsar.yaml
├── rustfs/
│   └── fleet.yaml
├── link.sh
└── Makefile
```

## Requirements

- Fleet CLI
- kubectl
- Docker

The pilot cluster and worker registration must already be available through the `clusters/` module.

## Install dependencies

```bash
make install
```

Individual dependencies can also be installed separately:

```bash
make envoy-gateway
make pulsar
make rustfs
```

## Envoy Gateway

Envoy Gateway is installed on worker clusters with one of the following roles:

```text
edge
processing
```

The Envoy Gateway Helm chart manages the Gateway API and Envoy Gateway CRDs required by the installation.

## Pulsar

Pulsar runs in standalone mode on the pilot cluster in:

```text
pulsar-system
```

The service is available to workloads through Kubernetes DNS:

```text
pulsar.pulsar-system.svc.cluster.local:6650
```

Workers can reach it through the worker-to-pilot service discovery configured by the `clusters/` module.

## RustFS

RustFS runs in standalone mode on the pilot cluster in:

```text
rustfs-system
```

It is exposed locally through the Kind cloud-provider ingress gateway.

Print the local URL with:

```bash
make rustfs-url
```

The resulting URL has the form:

```text
http://rustfs.localhost:<port>
```

The port is discovered from the `cloud-provider-kind` gateway container.
Default login credentials are rustadmin/rustadmin.

## Cleanup

Remove all dependency Fleet bundles:

```bash
make clean
```

Fleet cluster registration and the sandbox clusters themselves are managed separately by the `clusters/` module.