## ** HTTP **
# > several HTTP service

# NOTES: this are just placeholders for now

.PHONY: http
DEFAULT_HTTP ?= lighttpd
http: $(DEFAULT_HTTP) 

.PHONY: traefik
traefik:
	$(call apk_add, traefik traefik-doc)
	traefik

.PHONY: lighttpd
LIGHTTPD_OPTS ?= -f /app/lighttpd/lighttpd.conf
lighttpd: /usr/sbin/lighttpd
	lighttpd -D $(LIGHTTPD_OPTS)
/usr/sbin/lighttpd:
	$(call apk_add, lighttpd lighttpd-doc)
	$(shell mkdir -p /app/lighttpd)
	$(file >/tmp/patch_lighttpd_conf_app_dir,$(patch_lighttpd_conf_app_dir))
	cp /etc/lighttpd/* /app/lighttpd
	patch /app/lighttpd/lighttpd.conf /tmp/patch_lighttpd_conf_app_dir
define patch_lighttpd_conf_app_dir
7d593dfadb3f:/app# diff lighttpd.conf.orig lighttpd.conf
--- lighttpd.conf.orig
+++ lighttpd.conf
@@ -4,7 +4,7 @@
 ###############################################################################
 
 # {{{ variables
-var.basedir  = "/var/www/localhost"
+var.basedir  = "/app/lighttpd/www"
 var.logdir   = "/var/log/lighttpd"
 var.statedir = "/var/lib/lighttpd"
 # }}}
endef

.PHONY: pocketbase
# This is example of building go code, pocketbase itself is untested other than it starts
pocketbase: /usr/local/bin/pocketbase
	$(shell mkdir -p /app/pocketbase)
	/usr/local/bin/pocketbase serve /app/pocketbase 
/usr/local/bin/pocketbase:
	$(call apk_add, go, libffi-dev libgcrypt-dev libressl-dev)
	$(shell mkdir -p /usr/local/src/pocketbase)
	$(shell git clone https://github.com/pocketbase/pocketbase /usr/local/src/pocketbase)
	cd /usr/local/src/pocketbase/examples/base && go build -o pocketbase
	cp /usr/local/src/pocketbase/examples/base/pocketbase /usr/local/bin/pocketbase
#   PocketBase has a .gorelease.yml - but really just does same as above
#	GOBIN=/usr/local/bin go install github.com/goreleaser/goreleaser@latest
#	cd /usr/local/src/pocketbase && goreleaser release --snapshot --rm-dist
