SUFFIX           := vx0

RUBY_VERSION     := 2.0
RUBY             := vx-embeded-ruby-$(RUBY_VERSION)
BUNDLER          := vx-embeded-bundler-$(RUBY_VERSION)

GIT_ROOT         := $(shell git rev-parse --show-toplevel)
GIT_DATE         := $(shell git log -n1 --format="%aD")
GIT_BUILD_NUMBER := $(shell git rev-list HEAD | wc -l | sed -e 's/ *//g' | xargs -n1 printf %04d)
GIT_LAST_TAG     := $(shell git describe --abbrev=0 --tags)
GIT_VERSION      := $(shell echo $(GIT_LAST_TAG) | sed -e "s/^v//g")
GIT_VERSION      := $(shell echo $(GIT_VERSION) | ruby -e "puts Gem::Version.new(STDIN.read).release.to_s")

PACKAGE_VERSION  := $(shell echo $(GIT_VERSION) | ruby -e "puts Gem::Version.new(STDIN.read).release.to_s.split('.')[0..1].join('.')")
VERSION          := $(GIT_VERSION).git$(GIT_BUILD_NUMBER)~$(SUFFIX)
SOURCE_NAME      := vx-worker
PACKAGE_NAME     := $(SOURCE_NAME)-$(PACKAGE_VERSION)
PACKAGE          := $(PACKAGE_NAME)_$(VERSION)

WORK_DIR         := .tmp/$(SOURCE_NAME)
SOURCE_ARCHIVE   := $(SOURCE_NAME).tar.gz
ARCHIVE          := .tmp/$(SOURCE_ARCHIVE)

SRC              := $(wildcard *.mk)
DST              := $(patsubst %.mk,%,$(SRC))
OSC_ROOT         := .tmp/build
OSC_PROJECT      := home:dmexe:vexor
OSC_ARCHIVE      := $(OSC_ROOT)/$(SOURCE_ARCHIVE)

HOST             := vexor.io

clean:
	@echo " --> remove $(ARCHIVE) $(DST) $(OSC_ROOT)"
	@rm -rf $(ARCHIVE)
	@rm -f $(DST)
	@rm -rf $(OSC_ROOT)

build: $(OSC_ARCHIVE)
	@(cd $(OSC_ROOT) && osc build)

build-no-init: $(OSC_ARCHIVE)
	@(cd $(OSC_ROOT) && osc build --no-init)

release: $(OSC_ARCHIVE)
	@echo " --> commit to OBS"
	@(cd $(OSC_ROOT) && osc addremove)
	@(cd $(OSC_ROOT) && osc ci -m "bump")

copy: $(OSC_ARCHIVE)

$(OSC_ARCHIVE): $(ARCHIVE) $(DST)
	@echo " --> checkout $(OSC_PROJECT)/$(PACKAGE_NAME) to $(OSC_ROOT)"
	@test -d $(OSC_ROOT) || osc co $(OSC_PROJECT) $(PACKAGE_NAME) -o $(OSC_ROOT)
	@echo " --> complete remove old revision"
	@(cd $(OSC_ROOT) && ls --hide='.*' | xargs -I {} rm {})
	@echo " --> copy files"
	@cp * $(OSC_ROOT)
	@cp $(ARCHIVE) $(OSC_ARCHIVE)

$(ARCHIVE):
	@echo " --> export to $(WORK_DIR)"
	@rm -rf $(WORK_DIR)
	@mkdir -p $(WORK_DIR)
	@git --git-dir $(GIT_ROOT)/.git archive HEAD | tar -x -C $(WORK_DIR)
	@echo " --> packaging gems"
	@(cd $(WORK_DIR) && bundle package > /dev/null)
	@echo " --> create $@"
	@tar -zcf $(ARCHIVE) -C .tmp/ $(SOURCE_NAME)

% : %.mk
	@echo " --> create $@"
	@cat $< \
	| sed 's/%PACKAGE_NAME%/$(PACKAGE_NAME)/g' \
	| sed 's/%SOURCE_NAME%/$(SOURCE_NAME)/g' \
	| sed 's/%VERSION%/$(VERSION)/g' \
	| sed 's/%RUBY%/$(RUBY)/g' \
	| sed 's/%USER%/$(USER)/g' \
	| sed 's/%HOST%/$(HOST)/g' \
	| sed 's/%BUNDLER%/$(BUNDLER)/g' \
	| sed 's/%DATE%/$(GIT_DATE)/g' \
	> $@
