# *** _make.mk *** - The PID 1 of make.d
# > ... but just runs first from /app/Makefile, mainly helpers

# ** apk_add function ** - _safely_ adds packages using Alpine's "apk add"
APK_WAIT ?= 3600
APK_OPTS ?=
# causes package update from running make
APK_UPDATE = $(shell apk update)

### core helper functions for APK
apk_add = apk --wait $(APK_WAIT) $(APK_OPTS) add $(1)
apk_add_testing = apk --wait $(APK_WAIT) --no-cache add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing $(1)
build_apk_addgroup = apk --wait $(APK_WAIT) add --virtual $(1) $(2)
build_apk_cleanup = apk --wait $(APK_WAIT) del $(1)
apk_list_by_size = apk list -Iq | while read pkg; do apk info -s "$$pkg" | tac | tr '\n' ' ' | xargs | sed -e 's/\s//'; done | sort -h

## get machine type (used to detect arch)
UNAME_MACHINE = $(shell uname -m)
ifeq (,$(findstring armv,$(UNAME_MACHINE)))
$(info running on $(UNAME_MACHINE))
else
$(warning some services/tools are built from source - this may not work on low-end platforms)
endif

.PHONY: check-for-updates
check-for-updates:
	$(info checking for upgrade)
	apk update
	apk info -U
	apk stats

.PHONY: upgrade
upgrade: check-for-updates
	$(info update starting)
	apk update
	apk upgrade

.PHONY: install-everything install-all install-all-tools install-all-services install-all-built
install-everything: install-all install-all-built tools-all-langs
install-all: install-all-tools install-all-services install-all-built
install-all-tools: tools-extras tools-mail tools-games tools-dns tools-db tools-all-text tools-serial tools-all-vpns tools-video tools-files tools-cloud all-help add-python3 add-nodejs
install-all-services: add-mosquitto add-postgres add-bind9 add-blocky add-caddy add-traefik add-lighttpd
install-all-built: build-src

.PHONY: build-src build-src-linux build-src-go build-src-rust
build-src: build-src-linux build-src-go build-src-rust
ifeq (,$(findstring armv,$(UNAME_MACHINE)))
build-src-linux: add-midimonster add-librouteros-dev
build-src-go:
build-src-rust:  add-unmake
else
build-src-linux: add-midimonster add-librouteros-dev
build-src-go:
	$(warning build-src skips go for armv6 and armv7)
build-src-rust:
	$(warning build-src skips rust for armv6 and armv7)
endif

# these are just more "problematic", always skip them even when "all" and "everything"
.PHONY: stress-build-src
stress-build-src: build-src add-pocketbase add-erlang-tui add-cute-tui add-mdbook-man add-tsduck add-mdbook-man


# Essentially, some manually run "integration test" that installs everything
# to see failures from build.  It's not a pass/fail, although ideally all "should
# work", or been excluded on a platform, etc.
.PHONY: stress-services stress-services-nobuild stress-services-built stress-services-nobuild-unwise
stress-services: stress-services-nobuild stress-services-built stress-subcommands
stress-services-nobuild: TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS = :8082
stress-services-nobuild: sshd syslogd telnetd mqtt blocky lighttpd bind9 caddy traefik
stress-services-nobuild-unwise: postgres nodered
stress-services-built: pocketbase midimonster

.PHONY: stress-subcommands
stress-subcommands: git-init fossil-init

.PHONY: stress-everything
stress-everything: install-everything stress-services


