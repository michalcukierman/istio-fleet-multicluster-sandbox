# OVHcloud Remote Bootstrap

Creates a remote machine on OVHcloud for running the StreamX multicluster sandbox.

The default environment provisions:

- OVHcloud Public Cloud
- Warsaw (`WAW1`)
- `b3-64` instance
- Ubuntu 24.04
- public networking
- hourly billing
- per-user SSH key
- per-user instance name

No backups, additional volumes, private networks, gateways, or Floating IPs are created.

## Requirements

- OVHcloud CLI
- ssh-keygen
- Bash

## OVHcloud credentials

Create a `.ovhrc` file in this directory:

```bash
touch .ovhrc
chmod 600 .ovhrc
```

Add your OVHcloud API credentials:

```bash
export OVH_ENDPOINT="ovh-eu"
export OVH_APPLICATION_KEY=""
export OVH_APPLICATION_SECRET=""
export OVH_CONSUMER_KEY=""
```

Fill in the three credential values before provisioning.
The OVHcloud CLI supports these environment variables directly and checks them before its configuration files.

## Create the remote environment

```bash
make bootstrap
```

The instance and SSH key names are automatically scoped to the current local user:

```text
streamx-sandbox-<user>
```

For example:

```text
streamx-sandbox-michalcukierman
```

The local SSH private key is stored under:

```text
~/.ssh/streamx-sandbox-<user>
```

The corresponding public key is registered with OVHcloud automatically.

## Override defaults

Make variables can be overridden when needed:

```bash
NAME=my-sandbox \
REGION=WAW1 \
make bootstrap
```

The default values are:

```text
REGION=WAW1
NAME=streamx-sandbox-<user>
SSH_KEY_NAME=streamx-sandbox-<user>
```

## Cleanup

Remove the remote environment:

```bash
make clean
```

This removes:

- the OVHcloud instance
- the SSH key registration in OVHcloud

The local SSH private and public key files are preserved so they can be reused when the environment is created again.