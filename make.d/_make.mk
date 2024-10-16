# *** _make.mk *** - The PID 1 of make.d 
# > ... but just runs first from /app/Makefile, mainly helpers

# ** apk_add function ** - _safely_ adds packages using Alpine's "apk add"
APK_WAIT ?= 120
apk_add = apk --wait $(APK_WAIT) --no-cache add $(1)
apk_add_testing = apk --wait $(APK_WAIT) --no-cache add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing $(1)
build_apk_addgroup = apk --wait $(APK_WAIT) add --virtual $(1) $(2)
build_apk_cleanup = apk --wait $(APK_WAIT) del $(1)
apk_list_by_size = apk list -Iq | while read pkg; do apk info -s "$$pkg" | tac | tr '\n' ' ' | xargs | sed -e 's/\s//'; done | sort -h

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

.PHONY: install-all-tools
install-all-tools: all-extras all-games all-mail all-runtimes all-serial all-text all-databases all-help

.PHONY: git-save
git-save:
	git status
	git add --all
	git commit -m "make.d changes `date`"
	git status
 
# These are used for testing...
.PHONY: stress-everything stress-services stress-alls 
stress-everything: stress-services stress-alls 
stress-services: stress-services-nobuild stress-services-build
stress-alls: install-all-tools


.PHONY: stress-services-build stress-services-nobuild
stress-services-nobuild: netinstall mqtt nodered redis telnetd postgres blocky lighttpd BIND9_PORT=5353 bind9
stress-services-build: stress-build-rust stress-build-go stress-build-linux

.PHONY: stress-build-go stress-build-rust stress-build-linux
stress-build-go: pocketbase
stress-build-rust: cute-tui
stress-build-linux: midimonster
