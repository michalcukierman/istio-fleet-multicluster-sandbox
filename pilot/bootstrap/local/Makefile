CLUSTER_NAME ?= pilot

KUBECONFIG := ../../kubeconfig.yaml
KIND_CONFIG := kind.yaml

.PHONY: bootstrap check cluster cloud-provider clean

bootstrap: check cluster cloud-provider

check:
	@command -v kind >/dev/null 2>&1 || { echo "Missing required command: kind"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "Missing required command: docker"; exit 1; }

cluster: $(KUBECONFIG)

$(KUBECONFIG):
	@if kind get clusters | grep -qx "$(CLUSTER_NAME)"; then \
		echo "Kind cluster '$(CLUSTER_NAME)' already exists"; \
		kind get kubeconfig \
			--name "$(CLUSTER_NAME)" > "$(KUBECONFIG)"; \
	else \
		kind create cluster \
			--name "$(CLUSTER_NAME)" \
			--config "$(KIND_CONFIG)" \
			--kubeconfig "$(KUBECONFIG)"; \
	fi

cloud-provider:
	@if docker inspect -f '{{.State.Running}}' cloud-provider-kind 2>/dev/null | grep -q true; then \
		echo "cloud-provider-kind is already running"; \
	else \
		docker rm -f cloud-provider-kind 2>/dev/null || true; \
		docker run -d \
			--rm \
			--network kind \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name cloud-provider-kind \
			registry.k8s.io/cloud-provider-kind/cloud-controller-manager:v0.11.1; \
	fi

clean:
	-docker rm -f cloud-provider-kind >/dev/null 2>/dev/null
	-kind delete cluster --name "$(CLUSTER_NAME)"
	rm -f "$(KUBECONFIG)"