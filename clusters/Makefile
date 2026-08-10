ENVIRONMENT ?= local
export ENVIRONMENT

BOOTSTRAP_DIR := pilot/bootstrap/$(ENVIRONMENT)

ifeq ($(filter $(ENVIRONMENT),local remote),)
$(error ENVIRONMENT must be either 'local' or 'remote')
endif

.PHONY: \
	bootstrap \
	clusters \
	discovery \
	fleet \
	up \
	clean

up: bootstrap clusters discovery fleet

bootstrap:
	$(MAKE) -C $(BOOTSTRAP_DIR) bootstrap

clusters:
	$(MAKE) -C workers clusters

discovery:
	$(MAKE) -C discovery install

fleet:
	$(MAKE) -C fleet install

clean:
	$(MAKE) -C $(BOOTSTRAP_DIR) clean
	$(MAKE) -C workers clean