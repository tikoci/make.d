## ** HTTP **
# > several HTTP service

# NOTES: this are just placeholders for now

# port maps
# caddy-fileserver 8081
# traefik 80, 443, 8080

.PHONY: http
HTTP_SERVER_DEFAULT ?= lighttpd
http: $(HTTP_SERVER_DEFAULT)

# todo: only lighttpd is wired up well, caddy and traefik just install

.PHONY: add-caddy
add-caddy:
	$(call apk_add, caddy)

.PHONY: caddy
CADDY_OPTS ?= file-server -b -r /app -l 0.0.0.0:8081
caddy: add-caddy
	caddy $(CADDY_OPTS)

.PHONY: traefik
TRAEFIK_LOG_LEVEL ?= DEBUG
TRAEFIK_PROVIDERS_FILE_DIRECTORY ?= /app/traefik
TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS ?= :443
TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS ?= :80
TRAEFIK_API_INSECURE ?= true
# note: "export" causes make variables to be added called process's environment
#       normally env variables are passthrough, but if NOT set, make ?= catches that
#       since we do want some env var set for traefik if not provided
# ... i'm not sure export is allow on optional vars - but didn't work, thus the duplication here
export TRAEFIK_LOG_LEVEL
export TRAEFIK_PROVIDERS_FILE_DIRECTORY
export TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS
export TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS
export TRAEFIK_API_INSECURE
traefik: add-traefik
	traefik

.PHONY: add-traefik
add-traefik: /usr/sbin/traefik

.PRECIOUS: /usr/sbin/traefik
/usr/sbin/traefik:
	$(call apk_add, traefik traefik-doc)
	mkdir -p /app/traefik
	rm /etc/traefik/traefik.yaml

.PHONY: lighttpd
LIGHTTPD_OPTS ?= -f /app/lighttpd/lighttpd.conf
lighttpd: add-lighttpd
	lighttpd -D $(LIGHTTPD_OPTS)

.PHONY: add-lighttpd
add-lighttpd: /usr/sbin/lighttpd

.PRECIOUS: /usr/sbin/lighttpd
/usr/sbin/lighttpd:
	$(call apk_add, lighttpd lighttpd-doc)
	$(shell mkdir -p /app/lighttpd/www/htdocs)

	$(file >/tmp/patch_lighttpd_conf_app_dir,$(patch_lighttpd_conf_app_dir))
	cp /etc/lighttpd/* /app/lighttpd
	patch /app/lighttpd/lighttpd.conf /tmp/patch_lighttpd_conf_app_dir
	$(file >/app/lighttpd/www/htdocs/index.html,$(html_maked_sample))

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
POCKETBASE_HTTP ?= 0.0.0.0:8084
POCKETBASE_HTTPS ?= 0.0.0.0:7084
POCKETBASE_ORIGINS ?= *
POCKETBASE_DOMAIN ?= pocketbase.home.arpa
pocketbase: add-pocketbase 
	$(shell mkdir -p /app/pocketbase/data)
	$(shell mkdir -p /app/pocketbase/public)
	/usr/local/bin/pocketbase serve $(POCKETBASE_DOMAIN) --dir /app/pocketbase/data --publicDir /app/pocketbase/public --http $(POCKETBASE_HTTP) --https $(POCKETBASE_HTTPS) --origins $(POCKETBASE_ORIGINS)

.PHONY: add-pocketbase
add-pocketbase: /usr/local/bin/pocketbase
	$(shell mkdir -p /app/pocketbase)

.PRECIOUS: /usr/local/bin/pocketbase
/usr/local/bin/pocketbase:
	$(call build_apk_addgroup, .build-pocketbase, git go libffi-dev libgcrypt-dev libressl-dev)
	$(shell mkdir -p /usr/local/src/pocketbase)
	$(shell git clone https://github.com/pocketbase/pocketbase /usr/local/src/pocketbase)
	cd /usr/local/src/pocketbase/examples/base && go build -o pocketbase
	cp /usr/local/src/pocketbase/examples/base/pocketbase /usr/local/bin/pocketbase
	$(call build_apk_cleanup, .build-pocketbase)

#   PocketBase has a .gorelease.yml - but really just does same as above
#	   GOBIN=/usr/local/bin go install github.com/goreleaser/goreleaser@latest
#	   cd /usr/local/src/pocketbase && goreleaser release --snapshot --rm-dist

# "inline" HTML that is used as default homepage for webservices,
#    just single file that loads remote image

define html_maked_sample
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>make.d home.arpa</title>
	<style>
		@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400&display=swap');

		body, html {
			height: 100%;
			margin: 0;
			display: flex;
			align-items: center;
			justify-content: center;
			background-color: #f0f0f0;
			overflow: hidden;
			font-family: 'JetBrains Mono', monospace;
		}
		.container {
			position: relative;
			width: 100%;
			height: 100%;
			display: flex;
			align-items: center;
			justify-content: center;
		}
		img {
			width: 100%;
			height: 100%;
			object-fit: contain;
		}
		.centered-text {
			position: absolute;
			bottom: 4%;
			left: 0;
			width: 100%;
			background-color: black; /* Background for the terminal stripe */
			color: #00FF00; /* Terminal green text */
			font-size: 13vh; /* 20% of the viewport height */
			text-align: center;
			padding: 10px 0;
			line-height: 1;
		}
	</style>
</head>
<body>
	<div class="container">
		<img src="https://tikoci.github.io/_file/images/dalle-cubist-potto.6590b44e.webp" alt="Spanish Cubist Potto Art">
	</div>
		<div class="centered-text">make.d</div>
</body>
</html>
endef