# StreamX Multicluster Sandbox

Local development and test environment for running a StreamX multicluster topology and its supporting infrastructure.

The sandbox consists of:

- a pilot Kubernetes cluster
- K3k worker clusters
- worker-to-pilot service discovery
- Rancher Fleet for cluster registration and deployment
- Envoy Gateway
- Apache Pulsar
- RustFS

```text
streamx-multicluster-sandbox/
├── clusters/
├── dependencies/
├── Makefile
└── README.md
```

## Requirements

- Docker
- Kind
- kubectl
- Helm
- Fleet CLI
- envsubst

## Start the sandbox

```bash
make up
```

This creates the local multicluster environment and installs its dependencies.

## Cleanup

```bash
make clean
```

This removes deployed dependencies and the local cluster environment.

## Modules

### `clusters/`

Creates and configures the multicluster topology.

See [`clusters/README.md`](clusters/README.md).

### `dependencies/`

Installs infrastructure used by the sandbox through Rancher Fleet.

See [`dependencies/README.md`](dependencies/README.md).