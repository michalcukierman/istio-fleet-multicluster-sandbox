KUBECONFIG := ../clusters/pilot/kubeconfig.yaml
export KUBECONFIG

PILOT_NAMESPACE := fleet-local
WORKERS_NAMESPACE := fleet-default

.PHONY: \
	check \
	up \
	envoy-gateway \
	pulsar \
	rustfs \
	rustfs-url \
	clean

up: envoy-gateway pulsar rustfs

check:
	@command -v fleet >/dev/null 2>&1 || { echo "Missing required command: fleet"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }

envoy-gateway: check
	fleet apply --namespace $(WORKERS_NAMESPACE) \
		envoy-gateway \
		./envoy-gateway

pulsar: check
	fleet apply --namespace $(PILOT_NAMESPACE) \
		pulsar \
		./pulsar

rustfs: check
	fleet apply --namespace $(PILOT_NAMESPACE) \
		rustfs \
		./rustfs

rustfs-url:
	# FixMe: Think about the responsibility of links/domains mappins and settings
	@./link.sh \
		'io.x-k8s.cloud-provider-kind.gateway.name=pilot/rustfs-system/kind-ingress-gateway' \
		rustfs.localhost

clean:
	kubectl --namespace $(WORKERS_NAMESPACE) \
		delete bundle \
		--selector='streamx.com/dependency' \
		--ignore-not-found

	kubectl --namespace $(PILOT_NAMESPACE) \
		delete bundle \
		--selector='streamx.com/dependency' \
		--ignore-not-found
		
	# FixMe: CCM is not cleaning gateways
	# Makefile clusters/Makefile should cleanup this too
	# This does not work on k3s
	kubectl -n rustfs-system \
		delete gateway kind-ingress-gateway \
		--ignore-not-found || true