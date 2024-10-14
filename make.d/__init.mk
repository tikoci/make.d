## ** __init.mk **
# > stuff for use from a Dockerfile - NOT a running container

# todo: needs renaming, perhaps should include Makefile and this is NOT included...

.PHONY: init
init: base-apks base-files add-users
	$(info init run)

.PHONY: base-apks
# ** base-apks ** installs the core packages used by all other packages 
base-apks:
	apk add --no-cache \
		busybox-extras \
		make make-doc \
		mandoc man-pages mandoc-apropos mandoc-doc less less-doc busybox-doc \
		dropbear dropbear-doc dropbear-ssh dropbear-scp dropbear-dbclient \
		inetutils-telnet inetutils-ftp-doc \
		mosquitto-clients mqttui mqttui-bash-completion \
		curl curl-doc jq jq-doc jo jo-doc \
		git git-doc git-bash-completion gitui \
		patch patch-doc \
		nano nano-doc nano-syntax \
		bash bash-doc bash-completion ncurses ncurses-doc ncurses-terminfo
	apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing mdcat openapi-tui 
# add syntax coloring to nano (busybox vi does not support colors, so only nano has colors by default)
	echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc
#	update man page index
	$(shell makewhatis)


.PHONY: add-users
# add a "sysop" user for potential ssh/etc use
add-users:
	touch /etc/dropbear/authorized_keys
	adduser -D -s /bin/bash sysop && \
 	   echo -e "changeme\nchangeme\n" | passwd sysop
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

.PHONY: base-files
# ** base-files ** files set upon initalization of container
# note: all file targets must be listed as "base-files" 
base-files: replace-motd /usr/local/bin/mk /usr/local/bin/edit /usr/share/bash-completion/helpers/patch_mk_bash_completions


.PHONY: replace-motd
replace-motd:
	$(shell cat /VERSION > /etc/motd) 
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

Curated Alpine Linux tools are installed to work with RouterOS.
More tools & services ("daemons") can be added using `mk <recipe>`.
Using `bash`, hit TAB twice after `mk` shows recipes to make.

Most configuration files stored under /app, use `edit <file>`.
The default `nano` editor supports basic colors and syntax checks.

See https://github.com/tikoci/make.d for latest info.  
For more help, use `mk help`, and `mk commentary`.  

endef

define etc_motd_first


███╗   ███╗ █████╗ ██╗  ██╗███████╗   ██████╗ 
████╗ ████║██╔══██╗██║ ██╔╝██╔════╝   ██╔══██╗
██╔████╔██║███████║█████╔╝ █████╗     ██║  ██║
██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝     ██║  ██║
██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██╗██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ 

For help, use `man <command>`, or `man -k <search>`.

Curated small UNIX tools are also installed,
including bash, curl, jq, git, mqttui, mdless, and more.

Most configuration files stored under /app.
`edit <file>` uses EDITOR var, default is `nano`,
which supports basic colors and syntax checks.

See https://github.com/tikoci/make.d for more info.

endef

# todo: support some debug mode to add -d to make
MK_FLAGS ?= 
define usr_local_bin_mk
#!/bin/sh
SAVEDIR=`pwd`
cd /app
make $(MK_FLAGS) -j 1024 $$@
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