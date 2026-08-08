.PHONY: \
	bootstrap \
	bootstrap-remote \
	clusters \
	discovery \
	fleet \
	all \
	clean \
	clean-remote

all: clusters discovery fleet

bootstrap:
	$(MAKE) -C pilot/bootstrap/local bootstrap

bootstrap-remote:
	$(MAKE) -C pilot/bootstrap/remote bootstrap

clusters:
	$(MAKE) -C workers clusters

discovery:
	$(MAKE) -C discovery install

fleet:
	$(MAKE) -C fleet install

clean:
	$(MAKE) -C pilot/bootstrap/local clean
	$(MAKE) -C workers clean
	

clean-remote:
	$(MAKE) -C pilot/bootstrap/remote clean
	$(MAKE) -C workers clean
