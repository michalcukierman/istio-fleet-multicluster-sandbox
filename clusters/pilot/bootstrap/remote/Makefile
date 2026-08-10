REGION ?= WAW1
NAME ?= streamx-sandbox-$(shell whoami)

SSH_USER ?= ubuntu
SSH_KEY_NAME ?= streamx-sandbox-$(shell whoami)
SSH_KEY_PATH ?= $(HOME)/.ssh/$(SSH_KEY_NAME)

KUBECONFIG := ../../kubeconfig.yaml

OVHRC := .ovhrc

PROVISION_SCRIPT := provision.sh
DELETE_SCRIPT := delete.sh

export REGION
export NAME
export SSH_KEY_NAME
export SSH_KEY_PATH

.PHONY: \
	bootstrap \
	check \
	instance \
	k3s \
	clean

bootstrap: check instance k3s

check:
	@command -v ovhcloud >/dev/null 2>&1 || { echo "Missing required command: ovhcloud"; exit 1; }
	@command -v ssh-keygen >/dev/null 2>&1 || { echo "Missing required command: ssh-keygen"; exit 1; }
	@command -v ssh >/dev/null 2>&1 || { echo "Missing required command: ssh"; exit 1; }
	@command -v k3sup >/dev/null 2>&1 || { echo "Missing required command: k3sup"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "Missing required command: kubectl"; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "Missing required command: jq"; exit 1; }

	@test -f "$(OVHRC)" || { echo "Missing OVHcloud credentials file: $(OVHRC)"; exit 1; }

	@. "$(OVHRC)"; \
		test -n "$$OVH_ENDPOINT" || { echo "Missing OVH_ENDPOINT in $(OVHRC)"; exit 1; }; \
		test -n "$$OVH_APPLICATION_KEY" || { echo "Missing OVH_APPLICATION_KEY in $(OVHRC)"; exit 1; }; \
		test -n "$$OVH_APPLICATION_SECRET" || { echo "Missing OVH_APPLICATION_SECRET in $(OVHRC)"; exit 1; }; \
		test -n "$$OVH_CONSUMER_KEY" || { echo "Missing OVH_CONSUMER_KEY in $(OVHRC)"; exit 1; }

instance:
	@. "$(OVHRC)" && ./$(PROVISION_SCRIPT)

k3s:
	@. "$(OVHRC)"; \
	IP=$$(ovhcloud cloud instance list \
		--filter 'name=="$(NAME)"' \
		-o json | \
		jq -r '.[0].ipAddresses[].ip | select(contains(":") | not)' | \
		head -n 1); \
	if [ -z "$$IP" ]; then \
		echo "Public IPv4 address for '$(NAME)' not found"; \
		exit 1; \
	fi; \
	echo "Instance public IP: $$IP"; \
	echo "Waiting for SSH..."; \
	until ssh \
		-o IdentitiesOnly=yes \
		-o StrictHostKeyChecking=accept-new \
		-o ConnectTimeout=5 \
		-i "$(SSH_KEY_PATH)" \
		"$(SSH_USER)@$$IP" \
		true >/dev/null 2>&1; do \
			sleep 2; \
	done; \
	if [ -f "$(KUBECONFIG)" ] && \
		kubectl \
			--kubeconfig "$(KUBECONFIG)" \
			get nodes >/dev/null 2>&1; then \
		echo "K3s cluster is already available"; \
	else \
		echo "Installing K3s on $$IP"; \
		k3sup install \
			--ip "$$IP" \
			--user "$(SSH_USER)" \
			--ssh-key "$(SSH_KEY_PATH)" \
			--local-path "$(KUBECONFIG)" \
			--context pilot \
			--k3s-channel stable; \
	fi

clean:
	rm -f "$(KUBECONFIG)"
	@. "$(OVHRC)" && ./$(DELETE_SCRIPT)