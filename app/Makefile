.PHONY: \
	check \
	install \
	clean

KUBECONFIG := ../clusters/pilot/kubeconfig.yaml
export KUBECONFIG

FLEET_NAMESPACE ?= fleet-default

up: install

check:
	@command -v kubectl >/dev/null || (echo "kubectl is required" && exit 1)
	@command -v fleet >/dev/null || (echo "fleet is required" && exit 1)

install: check
	fleet apply --namespace $(FLEET_NAMESPACE) \
		sample \
		./sample

clean:
	kubectl --namespace $(FLEET_NAMESPACE) delete bundle sample-app \
		--ignore-not-found || true