#!/bin/sh

exec kubectl --kubeconfig ../../pilot/kubeconfig.yaml --namespace offloading port-forward service/k3k-offloading-service 6443:443
