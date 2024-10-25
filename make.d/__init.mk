## ** __init.mk **
# > stuff for use from a Dockerfile - NOT a running container

# todo: init- may be bad term, with []init[] connoting services control, not init[-ialization].

UNAME_MACHINE = $(shell uname -m)

.PHONY: init
init: init-apks init-dirs init-files init-users init-tls
	$(info init run)

.PHONY: init-apks
# ** init-apks ** installs the core packages used by all other packages
init-apks:
	$(info running on $(UNAME_MACHINE))
	apk add --no-cache \
		busybox-extras busybox-doc \
		make make-doc \
		mandoc man-pages mandoc-apropos mandoc-doc less less-doc \
		openssl openssl-doc openssh openssh-doc \
		curl curl-doc jq jq-doc jo jo-doc ca-certificates w3m \
		patch patch-doc \
		nano nano-doc nano-syntax \
		bash bash-doc bash-completion ncurses ncurses-doc ncurses-terminfo
#		dropbear dropbear-doc dropbear-ssh dropbear-scp dropbear-dbclient \
#		inetutils-telnet inetutils-ftp \
# add syntax coloring to nano (busybox vi does not support colors, so only nano has colors by default)
	echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
#	update man page index
	makewhatis


.PHONY: init-dirs
init-dirs:
	$(shell mkdir -p /app/.ssh)
	$(shell mkdir -p /app/make.d)
	$(shell mkdir -p /scratch)
	$(shell mkdir -p /hive)

.PHONY: init-users
# add a "sysop" user for potential ssh/etc use
init-users:
	adduser -D -s /bin/bash sysop && \
 	   echo -e "changeme\nchangeme\n" | passwd sysop
#	touch /etc/dropbear/authorized_keys
# todo: figure out ssh, or should just add more MB and use "real" sshd...
#	mkdir -p ~sysop/.ssh
#	dropbearkey -t rsa -f ~sysop/.ssh/id_rsa >> /etc/dropbear/authorized_keys
#	cat ~sysop/.ssh/authorized_keys >> /etc/dropbear/authorized_keys
#	chmod 700 /etc/dropbear
#	chmod 600 /etc/dropbear/authorized_keys
#	chmod 700 ~sysop/.ssh
#	chmod 600 ~sysop/.ssh/id_rsa
#	chmod 600 ~sysop/.ssh/authorized_keys
#	chown sysop ~sysop/.ssh
#	chown sysop ~sysop/.ssh/id_rsa
#	chown sysop ~sysop/.ssh/authorized_keys

.PHONY: init-files
# ** init-files ** files set upon initalization of container
# note: all file targets must be listed as "init-files"
init-files: replace-motd /usr/local/bin/mk /usr/local/bin/edit /usr/share/bash-completion/helpers/patch_mk_bash_completions

.PHONY: init-tls
init-tls: init-dirs
# used: openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -out localmail.crt -keyout localmail.key
	$(file >/app/.ssh/maked.key, $(app_maked_tls_key))
	$(file >/app/.ssh/maked.cert, $(app_maked_tls_cert))

.PHONY: replace-motd
replace-motd:
	$(shell cat /VERSION > /etc/motd)
	$(shell echo "" >> /etc/motd)
	$(file >>/etc/motd,$(etc_motd))

/usr/local/bin/mk:
	$(file >$@,$(usr_local_bin_mk))
	chmod +x $@

# add bash completions for the "mk" alias command, added to allow "make commands" from any directory
/usr/share/bash-completion/helpers/patch_mk_bash_completions: /usr/local/bin/mk
	$(file >/usr/share/bash-completion/helpers/patch_mk_bash_completions,$(patch_mk_bash_completions))
	cp /usr/share/bash-completion/completions/make /usr/share/bash-completion/completions/mk
	patch /usr/share/bash-completion/completions/mk /usr/share/bash-completion/helpers/patch_mk_bash_completions

/usr/local/bin/edit:
	$(file >$@,$(usr_local_bin_edit))
	chmod +x $@

define etc_motd

███╗   ███╗ █████╗ ██╗  ██╗███████╗   ██████╗
████╗ ████║██╔══██╗██║ ██╔╝██╔════╝   ██╔══██╗
██╔████╔██║███████║█████╔╝ █████╗     ██║  ██║
██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝     ██║  ██║
██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██╗██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝

For help, use `man <command>`, or `man -k <search>`.

Curated Alpine Linux tools installed to work with RouterOS.
More tools & services ("daemons") can be added using `mk <recipe>`.
Using `bash`, hit TAB twice after `mk` shows recipes to make.

Most configuration files stored under /app, use `edit <file>`.
The default `nano` editor supports basic colors and syntax checks.

See https://github.com/tikoci/make.d for latest info.
For more help, use `mk help`, and `mk commentary`.

endef

# todo: support some debug mode to add -d to make
MK_FLAGS ?= --debug=bjv
define usr_local_bin_mk
#!/bin/sh
SAVEDIR=`pwd`
cd /app
make $(MK_FLAGS) -j 32 $$@
cd $$SAVEDIR
endef

define usr_local_bin_edit
#!/bin/sh
$${EDITOR:-nano} $$@
endef

define patch_mk_bash_completions
--- make
+++ /usr/share/bash-completion/completions/mk
@@ -71,7 +71,8 @@
 _comp_cmd_make()
 {
     local cur prev words cword was_split comp_args
-    _comp_initialize -s -- "$$@" || return
+    _comp_initialize -s -- "$$@ -f /app/Makefile" || return
+    # note: cheat for make.d's mk command to force the makefile to make /app/Makefile for bash

     local makef makef_dir=("-C" ".") i

@@ -169,6 +170,6 @@

     fi
 } &&
-    complete -F _comp_cmd_make make gmake gnumake pmake colormake bmake
+    complete -F _comp_cmd_make mk

 # ex: filetype=sh
endef

define patch_make_bash_completions_old
--- make
+++ mk
@@ -169,6 +169,6 @@

     fi
 } &&
-    complete -F _comp_cmd_make make gmake gnumake pmake colormake bmake
+    complete -F _comp_cmd_make make gmake gnumake pmake colormake bmake mk

 # ex: filetype=sh
endef

define app_maked_tls_cert
-----BEGIN CERTIFICATE-----
MIIDezCCAmOgAwIBAgIUaLCVLpP6Y5vk41+LcQIO3qEjHCcwDQYJKoZIhvcNAQEL
BQAwTTELMAkGA1UEBhMCQVExEzARBgNVBAgMCkV2ZXJ5d2hlcmUxDzANBgNVBAoM
Bm1ha2UuZDEYMBYGA1UEAwwPbWFrZWQuaG9tZS5hcnBhMB4XDTI0MTAxOTIwMjAw
MloXDTM0MTAxNzIwMjAwMlowTTELMAkGA1UEBhMCQVExEzARBgNVBAgMCkV2ZXJ5
d2hlcmUxDzANBgNVBAoMBm1ha2UuZDEYMBYGA1UEAwwPbWFrZWQuaG9tZS5hcnBh
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv6vyCv/bCPhjsp+2Yx6c
egozYqMyUXHB71IyTDrf+z084OwnZai8M/erGN3m7aYl/JSiTItzUDaCb+H38yry
GjY8/Y1Aj84X1SEXuyRcTUHLCiQilkznfLMQ9FLMLTbP8YhwqBCq6pEd8TkRpCCX
/hvSRSxkNG5kinFQCzLBepcenmolbbcBdixbBqtIzYtifDa66j9mdct65ae5OgDg
U94tLB7nsdY2PoogW+dQWgj6kFyookVrvw+2a+kBUUDoKYJuyEtZXbLGdvOAdgZR
vBce9rDcb6CXhckP+8Se76WUxB5On/2jGDVxCPAhvzeuqhN14B2oHHS1GljUjKMG
hwIDAQABo1MwUTAdBgNVHQ4EFgQUjZkcnBbBKlJ87jCkSJo5Bs0wPf8wHwYDVR0j
BBgwFoAUjZkcnBbBKlJ87jCkSJo5Bs0wPf8wDwYDVR0TAQH/BAUwAwEB/zANBgkq
hkiG9w0BAQsFAAOCAQEAMNubb1VqI23f38Q48nLP3uwSksS7+YB4vwEmLurfDNpl
TjpYzFo1kAXsffU5BOwJ8tEHrGZnwWBdWqu6V8EzqZWqLmn9/tEsfSfEl17tlTcY
QBqKH47ISgl+FSGse5mJnI/cGxXJbbF/lynYuV8HENDW50CeB9en4w14PZbho1dV
DByC4b0j/WcP61LLU5NRN4/Tc3oA9SB+cQWo96GM3oep65HCv14EcpTIvH4t7FBz
FOOByJD+FpH7N5huk+6YrVfZ4AbjOZsylvPls64YQKtQxjtBH7+aSKEeFZY6HGll
Sl5YiqO2Jk9NG/rRL33ubJS9n1VEJDCXBgAhg8Ri4Q==
-----END CERTIFICATE-----
endef

define app_maked_tls_key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC/q/IK/9sI+GOy
n7ZjHpx6CjNiozJRccHvUjJMOt/7PTzg7CdlqLwz96sY3ebtpiX8lKJMi3NQNoJv
4ffzKvIaNjz9jUCPzhfVIRe7JFxNQcsKJCKWTOd8sxD0UswtNs/xiHCoEKrqkR3x
ORGkIJf+G9JFLGQ0bmSKcVALMsF6lx6eaiVttwF2LFsGq0jNi2J8NrrqP2Z1y3rl
p7k6AOBT3i0sHuex1jY+iiBb51BaCPqQXKiiRWu/D7Zr6QFRQOgpgm7IS1ldssZ2
84B2BlG8Fx72sNxvoJeFyQ/7xJ7vpZTEHk6f/aMYNXEI8CG/N66qE3XgHagcdLUa
WNSMowaHAgMBAAECggEAG5WLpD5Fb9liF7nZI2irYlDc1kw1mKJYzlqzobmItH06
qVqzIh6SKfRxwNwROOWuv9aa3jiPeYgZZi/3YXKDxyFDznBT+J4osI6DqMtx0S3a
d599rshrOXdXxaGzf/+hwNk+7/ZTcqXnJj5tUIPe++irGTNrSbRoGcMhnuBIwfMv
6C4H4lyyAaEL6U9jp+D3y9MWW2gfrMSvwN/dO6aCM86RrtIfzIt6HHi9MoLKP/r/
rQ/h/e71h/ovVogqBwDjsDWpieQ4OQxSwH4DNkC6ZVI3gWFbfsvSP6HI92TswqiP
lr2NqxmYZ0zcjKuYxnx5JypWMJyI7wZC8JCuBQ6nMQKBgQDeqlfd0aHYMJfsFYzr
X43lJ4l4WAGhT/SilwXN0A1y0WHGGcW34qING21FXeEWuNjpOWL9alI/5wXuxno5
E7DjNIYc4kXYuxoNCT34f6NQ5IiJnDTxV2aNyJSqdpA/UQFjcHKXW/bkrEdPN2E9
CQG8y6t8p9Yw9XcoGJjhYEwqSQKBgQDcXcQyoHkbvvgavF9TwnWKhMbSzX1V+9Jc
fphFoYch/Yw0VOFRNnugoRzdSukd3CTQGKiljP0u7ks2TiWG944VH0qbJDGUNz3m
zEMiD9kejYNuuO0LBOtzL1IAf+7NhbmMFWI4gEaYwnHQYqiYKthEckZaLwWe60xt
ndkj9KIqTwKBgQCbJ/HQRLpVLg8+2Al5Hf1/N5yoOhLwuAlMnpXRw28LmfFanCzV
JNws6/aphnBJaAbmBTIASe0EUFQm/TC/wwPYXooxaE6pZj8R5GXFWhOQU5783Ndb
cL6qf6FwYuvC4wxnoTyIUfHpiE6sWXetkzAdwYI+e6laNkGQtAsbyQFp2QKBgCa5
v6nZ846Br94a7nGswbU3Ai23eOgsWdpxUNcjvLincwUbSYFZHr6qsYTeDjt2HW4I
d1KohTHDJKqFbyjZxjlGB3leEexnDNTLXpzUxiYNXmSN0PJXyfyy+yklUlUBxAqv
E1S0jjN4MEIbpF8hYGIe5uggTU+RMBwvWiJscjcXAoGAW7zsRthjTgq3D06/0qhp
S7m4+5cyXvN7alz6us6nbdTeDi4Y6XDzgMLJZz5ra2AdJ9J8Y5dZ7jcuoLPM7w0G
Nx+Yuq7yLw4aAkEHVnLnejvoeb1f7CGDEvmq2S/1UGVpJvMgDvN7j9riDXSLsXa6
Mdll/rrBFdLU7w5brm14IX0=
-----END PRIVATE KEY-----
endef