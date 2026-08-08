.PHONY: \
	bootstrap-local \
	bootstrap-remote \
	clusters \
	istio \
	fleet \
	all \
	clean-local \
	clean-remote

all: clusters istio fleet

bootstrap-local:
	$(MAKE) -C pilot/bootstrap/local bootstrap

bootstrap-remote:
	$(MAKE) -C pilot/bootstrap/remote bootstrap

clusters:
	$(MAKE) -C workers clusters

istio:
	$(MAKE) -C istio install

fleet:
	$(MAKE) -C fleet install

clean-local:
	$(MAKE) -C pilot/bootstrap/local clean

clean-remote:
	$(MAKE) -C pilot/bootstrap/remote clean