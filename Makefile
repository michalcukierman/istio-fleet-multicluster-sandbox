.PHONY: \
	up \
	clean

up:
	$(MAKE) -C clusters bootstrap
	$(MAKE) -C clusters all
	$(MAKE) -C dependencies install

clean:
	$(MAKE) -C dependencies clean
	$(MAKE) -C clusters clean