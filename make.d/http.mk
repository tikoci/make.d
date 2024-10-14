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

# "inline" HTML that is used as default homepage for webservices, 
#    just single file that loads remote image

define html_maked_sample
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Image with Terminal Stripe Text</title>
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