KUBECONFIG := ../pilot/kubeconfig.yaml
export KUBECONFIG

CLUSTER_TEMPLATE := ./cluster.yaml

WORKERS := $(patsubst ../workers/%/.,%,$(wildcard ../workers/*/.))
REGISTER_TARGETS := $(addprefix register-,$(WORKERS))

FLEET_NAMESPACE := fleet-default

.PHONY: \
	check \
	manager \
	install

install: check manager $(REGISTER_TARGETS)

check:
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "Missing required command: helm"; exit 1; }

manager:
	helm repo add fleet https://rancher.github.io/fleet-helm-charts/ --force-update

	helm upgrade --install \
		--namespace cattle-fleet-system \
		--create-namespace \
		--wait \
		fleet-crd fleet/fleet-crd

	kubectl config view \
		--raw \
		--minify \
		-o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | \
		base64 --decode > .pilot-ca.pem

	@PILOT_API=$$(kubectl \
		get service kubernetes \
		--namespace default \
		-o jsonpath='{.spec.clusterIP}'); \
	helm upgrade --install \
		--namespace cattle-fleet-system \
		--create-namespace \
		--wait \
		--set apiServerURL="https://$$PILOT_API:443" \
		--set-file apiServerCA=.pilot-ca.pem \
		fleet fleet/fleet

	@rm -f .pilot-ca.pem

	kubectl create namespace $(FLEET_NAMESPACE) 2>/dev/null || true

register-%:
	@echo "Registering worker cluster '$*'"

	kubectl --namespace $* get secret k3k-$*-kubeconfig \
		-o jsonpath='{.data.kubeconfig\.yaml}' | \
		base64 --decode | \
	kubectl --namespace $(FLEET_NAMESPACE) create secret generic $*-kubeconfig \
		--from-file=value=/dev/stdin \
		--dry-run=client \
		-o yaml | \
	kubectl apply -f -

	CLUSTER_NAME=$* envsubst < $(CLUSTER_TEMPLATE) | \
		kubectl apply -f -