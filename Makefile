ENVIRONMENT ?= local

.PHONY: \
	up \
	clean

up:
	$(MAKE) -C clusters up
	$(MAKE) -C dependencies up

clean:
	$(MAKE) -C dependencies clean
	$(MAKE) -C clusters clean