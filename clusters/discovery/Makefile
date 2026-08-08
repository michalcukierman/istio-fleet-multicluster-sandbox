KUBECONFIG := ../pilot/kubeconfig.yaml
export KUBECONFIG

WORKERS := $(patsubst ../workers/%/.,%,$(wildcard ../workers/*/.))
DISCOVERY_TARGETS := $(addprefix discovery-,$(WORKERS))

.PHONY: \
	check \
	install

install: check $(DISCOVERY_TARGETS)

check:
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }

discovery-%:
	@echo "Configuring pilot service discovery on worker '$*'"
	@PILOT_DNS=$$(kubectl \
		--namespace kube-system \
		get service kube-dns \
		-o jsonpath='{.spec.clusterIP}'); \
	kubectl \
		--namespace $* \
		exec k3k-$*-server-0 -- sh -c \
		"kubectl \
			--namespace kube-system \
			get configmap coredns -o yaml | \
		sed 's/fallthrough in-addr.arpa ip6.arpa/fallthrough cluster.local in-addr.arpa ip6.arpa/' | \
		kubectl replace -f - && \
		kubectl \
			--namespace kube-system \
			create configmap coredns-custom \
			--from-literal=pilot.override='forward cluster.local $$PILOT_DNS' \
			--dry-run=client \
			-o yaml | \
		kubectl apply -f -"