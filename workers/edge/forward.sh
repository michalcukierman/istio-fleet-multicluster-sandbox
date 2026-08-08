#!/bin/sh

exec kubectl --kubeconfig ../../pilot/kubeconfig.yaml --namespace edge port-forward service/k3k-edge-service 6443:443
