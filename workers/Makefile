KUBECONFIG := ../pilot/kubeconfig.yaml
export KUBECONFIG

CLUSTER_TEMPLATE := ./cluster.yaml
FORWARD_TEMPLATE := ./forward.sh

WORKERS := $(patsubst %/,%,$(wildcard */))
WORKER_TARGETS := $(addprefix cluster-,$(WORKERS))
KUBECONFIG_TARGETS := $(addprefix kubeconfig-,$(WORKERS))

.PHONY: \
	check \
	operator \
	clusters \
	clean

clusters: check operator $(WORKER_TARGETS) $(KUBECONFIG_TARGETS)

check:
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "Missing required command: helm"; exit 1; }
	@command -v envsubst >/dev/null 2>&1 || { echo "Missing required command: envsubst"; exit 1; }

operator:
	helm repo add k3k https://rancher.github.io/k3k --force-update
	helm upgrade --install \
		--namespace k3k-system \
		--create-namespace \
		k3k k3k/k3k

cluster-%:
	kubectl \
		create namespace $* 2>/dev/null || true

	@echo "Creating worker cluster '$*'"
	CLUSTER_NAME=$* envsubst < $(CLUSTER_TEMPLATE) | \
		kubectl \
			apply -f -

kubeconfig-%:
	@echo "Waiting for worker cluster '$*' server"
	@until kubectl --namespace $* get pod k3k-$*-server-0 >/dev/null 2>&1; do \
			sleep 1; \
	done

	kubectl --namespace $* wait --for=condition=Ready \
		pod/k3k-$*-server-0 \
		--timeout=5m

	@echo "Getting worker cluster '$*' kubeconfig"

	kubectl --namespace $* exec k3k-$*-server-0 -- \
		cat /etc/rancher/k3s/k3s.yaml \
		> $*/kubeconfig.yaml
	
	CLUSTER_NAME=$* envsubst < $(FORWARD_TEMPLATE) > $*/forward.sh
	chmod +x $*/forward.sh

clean:
	@for worker in $(WORKERS); do \
		rm -f $$worker/kubeconfig.yaml; \
	done