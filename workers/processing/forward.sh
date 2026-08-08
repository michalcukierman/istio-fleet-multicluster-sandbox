#!/bin/sh

exec kubectl \
  --kubeconfig ../../pilot/kubeconfig.yaml \
  --namespace processing \
  port-forward service/k3k-processing-service 6443:443