#!/usr/bin/make -f

GEM    := /opt/vexor/bin/gem
BUNDLE := /opt/vexor/bin/bundle

GEMDIR := $(shell $(GEM) env gemdir)
DST    := ./debian/%PACKAGE_NAME%

%:
	dh $@

override_dh_auto_build:
	$(BUNDLE) --version
	$(BUNDLE) install --local --standalone --without test
