## ** HELP **
# > Help system and "notes"

.PHONE: all-help
all-help: help commentary

.PHONY: help
help: help-update
	cat /etc/motd
	$(warning Help is work-in-progress...)

commentary: notes-container-use notes-tips notes-future-fixes notes-future-recipes notes-implementation
	$(info )
	$(info ... last tip: targets can be combines, in help so `mk help commentary` run boths)
	$(info )

# help function that gets a list of man pages 
list_manpages = apropos -s $(1) .

.PHONY: list-recipes
list-recipes:
	make -npq -f /app/Makefile | awk -f /usr/share/bash-completion/helpers/make-extract-targets.awk | sort

.PHONY: list-commands
list-commands:
	CMDS = $(call list_manpages, 1)
	CMDS += $(call list_manpages, 8)
	echo $(CMDS) | sort | less

.PHONY: list-games
list-games: all-games
	$(call list_manpages, 6) | less

help-update:
	$(info help-update just re-indexes man pages for man -k)
	makewhatis


.PHONY: notes-tips
notes-tips:
	$(warning ** make.d TIPS **)
	$(info - make.d adds two scripts: `mk` and `edit` - the rest is in Makefile in /app)
	$(info - `edit` follows $$EDITOR var - `nano` is default and shows syntax error+colors)
	$(info - `mk` just wraps `make -f /app/Makefile ...` but shorter & work from any `pwd`)
	$(info - bash <tab><tab> completions are included - in root shell, type `bash` first)
	$(info - ... and this includes `mk` will list `make` targets with mk<tab><tab>.)
	$(info - manpages too - use man <command>, or man -k <topic>)
	$(info - for viewing in color with paging use `mdless` (& `mdcat`))
	$(info - the "shell jobs" cmds can be useful, see JOB CONTROL section in `man bash`)
	$(info   ... or try ^Z from longer make to "suspend", then `bg %1` to background it ) 
	$(info - /app is a `git` repo, even if not used to "checkin" - can see diff's from defaults) 
	$(info   ... use `git status` to see all changes, `git diff <file>` for one file ) 


.PHONY: notes-container-use
notes-container-use:
	$(info ** ROUTEROS CONTAINER USAGE **)
	$(info - Create a new container using this image, no mount or env are strickly needed)
	$(info - In RouterOS, using dst-nat for incoming ports to make.d)
	$(info   & src-nat outbound to enable internet is likely easiest config)
	$(info - /container's cmd= is used to control what services _actually_ run.) 
	$(info   To run daemons, just set `cmd=` with recipes to start like "nodered" or "mqtt".)
	$(info  `make` is not picky on order, recipes and KEY=val vars can be mixed.)
	$(info - To test in /container/shell first, use `mk <recipe> [<recipe>]... &`, note ampersand)
	$(info - Options like BIND9_PORT=80 can be provided via "envs", instead of in `cmd=`.)


.PHONY: notes-future-fixes
# just for fun, targets can just output text, here "todo" 
notes-future-fixes: 
	$(warning ** META BUGS **)
	$(info - proper README.md at least) 
	$(info   and some better help system, perhaps a 'helpme' command?)
	$(info   plus routeros-side script/config/examples to use make.d services) 
	$(info - syslogd is wired up, but more pkgs use, and vars for remote syslog) 
	$(info - default "sysop" user is untest... generally dealing users+permissions+keys)
	$(info - test/cleanup invoking browser from CLI, at least via shh)
	$(info - need some tools to test/use RADIUS from user-manager)
	$(info - more meta data and package dep tracking, TBD method)
	$(info - sometimes git is slow, perhaps git config --global http.postBuffer 157286400 ?)

.PHONY: notes-future-recipes
notes-future-recipes:	
	$(warning *** RECIPES IN THE WORKS **)
	$(info lora - [priority] some small LoRa network server ... lorawan-server? chripstack?)
	$(info dns - currently blocky and bind9, but add unbound just round out)
	$(info http - lighttpd plugins, plus basiec traefik as first two)
	$(info mail - [WIP] exim dovecot? imap?)
	$(info vpn - [idea] wg* zerotier*)
	$(info remote - [idea] X11? rdp? vnc?)
	$(info directory - [idea] openldap++ nis+?)
	$(info rtp - [idea] various audio-video utils)
	$(info tuitools - [more google search] find/add more nice TUIs, like current mqttui)
	$(warning make.d recipes are easy - testing and documenting them is harder)

.PHONY: notes-implementation
notes-implementation:
	$(warning ** BUILDING NEW RECIPES **)
	$(info - GNU make manual is excellent!  Search that first.)
	$(info   Questions like WTF is .ONESHELL or two-pass variable eval will be answered.) 
	$(info   ...in terminal, use `mk help` once, then `info make` to view GNU make manual)
	$(info   ...via web: https://www.gnu.org/software/make/manual ) 
	$(info - Check *.mk for examples - just adding a new .mk file to /app/make.d add them to `mk`) 
	$(info   ...so cut-and-paste may work to get you started) 
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