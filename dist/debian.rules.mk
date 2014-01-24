#!/usr/bin/make -f

GEM    := /opt/vexor/bin/gem
BUNDLE := /opt/vexor/bin/bundle

GEMDIR := $(shell $(GEM) env gemdir)
DST    := ./debian/%PACKAGE_NAME%

%:
	dh $@

override_dh_auto_build:
	$(GEM) --version
	$(GEM) build %SOURCE_NAME%.gemspec
	GEM_HOME=$(DST)/$(GEMDIR) $(GEM) install vendor/cache/*.gem *.gem --no-ri --no-rdoc --ignore-dependencies || true

override_dh_installinit:
	dh_installinit --name vx-worker
