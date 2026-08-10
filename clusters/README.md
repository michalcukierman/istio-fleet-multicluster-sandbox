# StreamX Multicluster Sandbox

Development and test environment for running a StreamX multicluster topology on a single machine or remote K3s host.

## Topology

- one pilot cluster
- multiple K3k worker clusters
- worker-to-pilot service discovery through CoreDNS
- Rancher Fleet for worker registration and deployment

Worker clusters are defined by directories under `workers/`.

```text
workers/
├── edge/
├── offloading/
└── processing/
````

The directory name is used as the cluster name and role.

## Requirements

Local environment:

* Docker
* Kind
* kubectl
* Helm
* envsubst

Remote environment:

* k3sup
* kubectl
* Helm
* envsubst

## Create a local environment

```bash
make up
```

## Create a remote environment

```bash
ENVIRONMENT=remote make up
```

## Add a worker cluster

Create a new directory:

```bash
mkdir workers/<name>
```

Then reconcile the environment:

```bash
make up
```

## Access a worker cluster

Each worker contains a generated kubeconfig and port-forward helper:

```text
workers/<name>/
├── kubeconfig.yaml
└── forward.sh
```

Start the API tunnel:

```bash
workers/processing/forward.sh
```

Then, in another terminal:

```bash
kubectl \
  --kubeconfig workers/processing/kubeconfig.yaml \
  get nodes
```

Only one worker tunnel can use local port `6443` at a time.

## Service discovery

Workers resolve their own Kubernetes Services first.

If a `cluster.local` service does not exist in the worker, the DNS query is forwarded to the pilot cluster.

This allows worker workloads to access pilot services using regular Kubernetes names:

```text
<service>.<namespace>.svc.cluster.local
```

## Cleanup

Local:

```bash
make clean
```

Remote:

```bash
ENVIRONMENT=remote make clean
```
