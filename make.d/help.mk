## ** HELP **
# > Help system and "notes"

.PHONY: all-help
all-help: help commentary

.PHONY: help
help:
	cat /etc/motd
	$(warning Help is work-in-progress...)

.PHONY: commentary
commentary: notes-container-use notes-tips notes-open-issues notes-future-recipes notes-building-new-recipes
	$(info )
	$(info ... last tip: targets can be combines, in help so `mk help commentary` run boths)
	$(info )

# help function that gets a list of man pages
list_manpages = apropos -s $(1) .

.PHONY: help-job-control 
help-job-control:
	man bash | less -p "^JOB CONTROL"

.PHONY: list-recipes
list-recipes:
	make -npq -f /app/Makefile | awk -f /usr/share/bash-completion/helpers/make-extract-targets.awk | sort

.PHONY: list-commands
list-commands:
	CMDS = $(call list_manpages, 1)
	CMDS += $(call list_manpages, 8)
	echo $(CMDS) | sort | less

.PHONY: list-games
list-games: tools-games
	$(call list_manpages, 6) | less

help-update:
	$(info help-update just re-indexes man pages for man -k)
	makewhatis


.PHONY: notes-tips
notes-tips:
	$(warning -- make.d TIPS --)
	$(info - make.d adds two scripts: `mk` and `edit` - the rest is in Makefile in /app)
	$(info - `edit` follows $$EDITOR var - `nano` is default and shows syntax error+colors)
	$(info - `mk` just wraps `make -f /app/Makefile ...` but shorter & work from any `pwd`)
	$(info - bash <tab><tab> completions are included - in root shell, type `bash` first)
	$(info - ... and this includes `mk` will list `make` targets with mk<tab><tab>.)
	$(info - manpages too - use man <command>, or man -k <topic>)
	$(info - for viewing in color with paging use `mdless` (& `mdcat`))
	$(info - the "shell jobs" cmds can be useful, see JOB CONTROL section in `man bash`)
	$(info   ... or try ^Z from longer make to "suspend", then `bg %1` to background it )
	$(info - sshd can be used with user `sysop`, password `changeme`)
	$(info   but `sysop` is not an admin/root, so mainly for running UNIX tools via /system/ssh-exec)


.PHONY: notes-container-use
notes-container-use:
	$(warning -- ROUTEROS CONTAINER USAGE --)
	$(info - Create a new container using this image, no mount or env are strickly needed)
	$(info - In RouterOS, using dst-nat for incoming ports to make.d)
	$(info   & src-nat outbound to enable internet is likely easiest config)
	$(info - /container's cmd= is used to control what services _actually_ run.)
	$(info   To run daemons, just set `cmd=` with recipes to start like "nodered" or "mqtt".)
	$(info  `make` is not picky on order, recipes and KEY=val vars can be mixed.)
	$(info - To test in /container/shell first, use `mk <recipe> [<recipe>]... &`, note ampersand)
	$(info - Options like BIND9_PORT=80 can be provided via "envs", instead of in `cmd=`.)


.PHONY: notes-open-issues
# just for fun, targets can just output text, here "todo"
notes-open-issues:
	$(warning -- OPEN ISSUES --)
	$(info - docs: proper README.md at least)
	$(info - make: package deps need work: make deps should ALWAYS be files as .PHONY always run "apk")
	$(info - make: $$(file X) should be own target, not part of a recipes )
	$(info - "on-demand" loading: scripts added that call make to get packages )
	$(info - shell: alias for vi if not installed to vim,nvim,hx,...pico) 
	$(info - "help": perhaps a `helpme` command, perhaps using mdbook for local http and man)
	$(info - "edit": support using recipe like "edit mosquitto" to open a service's config file) 
	$(info - basic http dev: add PHP/HTMX/Pico/Observable to lighttpd)
	$(info - syslogd: wired up, but no package wired to potentially use it)
	$(info - shell:  support ANSI code to make URL link (at least for SSH))
	$(info - shell: "sysop"/users: one created for like ssh, but needs more setup/thought)
	$(info - shell: /etc/services updated, to use in some TBD inetd-like port mapping scheme) 
	$(info - make: regularize /scratch for tmp and /hive as "shared" /app dir across instances)
	$(info - make: cargo install needs a function/thought)
	$(warning - config: variables are need everywhere to control services) 
	$(info - config: git vs fossil, +.mk script should save their own changes) 
	$(info - config: should have some option to `tar` or lightweight backup CLI to just copy/save files like ) 
	$(info - routeros+: script/config/examples to use make.d services)
	$(info - routeros+: test/wrap freeradius tools from user-manager)
	$(info - routeros+: bash completions outputs annoying cgroup error from one of them...)
	$(info - sshd: dropbear sucks, and openssl get installed by curl, use normal sshd...)
	$(info - make: service start != install in ALL cases, stress-build* so can build without starting )

.PHONY: notes-future-recipes
notes-future-recipes:
	$(warning -- RECIPES IN THE WORKS --)
	$(info lora - [priority] some small LoRa network server ... lorawan-server? old and does not work erlang package)
	$(info dns - currently blocky and bind9, but add unbound just round out)
	$(info dns - add DDNS service updates)
	$(info http - lighttpd plugins, plus basiec traefik as first two)
	$(info mail - [WIP] exim dovecot? imap?)
	$(info vpn - [idea] wg* zerotier*)
	$(info remote - [idea] X11? rdp? vnc?)
	$(info directory - [idea] openldap++ nis+?)
	$(info rtp - [idea] various audio-video utils)
	$(info tuitools - [more google search] find/add more nice TUIs, like current mqttui)
	$(warning make.d recipes are easy - testing and documenting them is harder)

.PHONY: notes-building-new-recipes
notes-building-new-recipes:
	$(warning -- BUILDING NEW RECIPES --)
	$(info - GNU make manual is excellent!  Search that first.)
	$(info   Questions like WTF is .PHONY, or two-pass variable eval will be answered.)
	$(info   ...in terminal, use `mk help` once, then `info make` to view GNU make manual)
	$(info   ...via web: https://www.gnu.org/software/make/manual )
	$(info - Check *.mk for examples - just adding a new .mk file to /app/make.d add them to `mk`)
	$(info   ...so cut-and-paste may work to get you started)
	$(info - Makefiles use TAB for indentation - using spaces is invalid + cause errors)
	$(info - All paths used must be FULLY QUALIFIED - do not expect PATH to work in any target)
	$(info   & also CRITICAL all new recipes have .PHONY if they are not real files!)
	$(info - .PRECIOUS is used when a target file is installed by a package - to prevent make from del on failure!)
	$(info - `make` looks for a Makefile in `pwd`, `mk` uses -f /app/Makefile to avoid that)
	$(info - You'll note `make -J ...` controls parallel runners)
	$(info   & what allow multiple services/daemons to run at same time & critical)
	$(info - `$$(info|warning|error text)` are builtin functions - but "error" will ALSO terminate)
	$(info - Do not overuse "quotes" when in variables - subtly called process args can get messed up)
	$(info - $$(varname) are make variables, while "double dollars" $$$$varname is for shell variables inside a recipe)
	$(info   Backslash \ is NOT an escape in make! In code, above uses 4 dollars $$$$$$$$ (and 8 in Makefile here))
	$(info   And, yes, escaping – patch files need to some $$$$ love too, otherwise patch will fail)

# MAN SECTIONS
#    1         General commands (tools and utilities).
#    2         System calls and error numbers.
#    3         Library functions.
#    3p        perl(1) programmer's reference guide.
#    4         Device drivers.
#    5         File formats.
#    6         Games.
#    7         Miscellaneous information.
#    8         System maintenance and operation commands.
#    9         Kernel internals.
