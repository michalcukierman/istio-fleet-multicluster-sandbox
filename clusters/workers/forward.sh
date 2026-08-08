#!/bin/sh

exec kubectl \
  --kubeconfig ../../pilot/kubeconfig.yaml \
  --namespace ${CLUSTER_NAME} \
  port-forward service/k3k-${CLUSTER_NAME}-service 6443:443