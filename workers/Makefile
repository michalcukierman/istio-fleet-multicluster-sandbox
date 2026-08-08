PILOT_KUBECONFIG := ../pilot/kubeconfig.yaml
CLUSTER_TEMPLATE := ./cluster.yaml

WORKERS := $(patsubst %/,%,$(wildcard */))
WORKER_TARGETS := $(addprefix cluster-,$(WORKERS))

.PHONY: \
	check \
	operator \
	clusters

clusters: check operator $(WORKER_TARGETS)

check:
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "Missing required command: helm"; exit 1; }
	@command -v envsubst >/dev/null 2>&1 || { echo "Missing required command: envsubst"; exit 1; }

operator:
	helm repo add k3k https://rancher.github.io/k3k --force-update
	helm upgrade --install \
		--kubeconfig $(PILOT_KUBECONFIG) \
		--namespace k3k-system \
		--create-namespace \
		k3k k3k/k3k

cluster-%:
	@echo "Creating worker cluster namespace '$*'"
	kubectl \
		--kubeconfig $(PILOT_KUBECONFIG) \
		create namespace $* 2>/dev/null || true
	@echo "Creating worker cluster '$*'"
	CLUSTER_NAME=$* envsubst < $(CLUSTER_TEMPLATE) | \
		kubectl \
			--kubeconfig $(PILOT_KUBECONFIG) \
			apply -f -