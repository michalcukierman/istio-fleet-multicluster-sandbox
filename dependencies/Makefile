KUBECONFIG := ../clusters/pilot/kubeconfig.yaml
export KUBECONFIG

-include ../clusters/pilot/runtime.env
export PILOT_IP

PILOT_NAMESPACE := fleet-local
WORKERS_NAMESPACE := fleet-default

.PHONY: \
	check \
	up \
	envoy-gateway \
	gateway-class \
	pulsar \
	rustfs \
	clean

up: traefik envoy-gateway gateway-class pulsar rustfs

check:
	@command -v fleet >/dev/null 2>&1 || { echo "Missing required command: fleet"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }

traefik: check
	fleet apply --namespace $(PILOT_NAMESPACE) \
		traefik \
		./traefik

envoy-gateway: check
	fleet apply --namespace $(WORKERS_NAMESPACE) \
		envoy-gateway \
		./envoy-gateway

gateway-class: check
	fleet apply --namespace $(WORKERS_NAMESPACE) \
		gateway-class \
		./gateway-class

pulsar: check
	fleet apply --namespace $(PILOT_NAMESPACE) \
		pulsar \
		./pulsar

rustfs: check
	@if [ -n "$(PILOT_IP)" ]; then \
		RUSTFS_HOST="rustfs.$(PILOT_IP).nip.io"; \
	else \
		RUSTFS_HOST="rustfs.localhost"; \
	fi; \
	RUSTFS_HOST="$$RUSTFS_HOST" \
	envsubst < ./rustfs/values.yaml.tmpl > ./rustfs/values.yaml

	fleet apply \
		--namespace $(PILOT_NAMESPACE) \
		rustfs \
		./rustfs

	rm -f ./rustfs/values.yaml

clean:
	kubectl --namespace $(WORKERS_NAMESPACE) \
		delete bundle \
		--selector='streamx.com/dependency' \
		--ignore-not-found || true

	kubectl --namespace $(PILOT_NAMESPACE) \
		delete bundle \
		--selector='streamx.com/dependency' \
		--ignore-not-found || true
		
	# FixMe: CCM is not cleaning gateways
	# Makefile clusters/Makefile should cleanup this too
	# This does not work on k3s
	kubectl -n rustfs-system \
		delete gateway kind-ingress-gateway \
		--ignore-not-found || true