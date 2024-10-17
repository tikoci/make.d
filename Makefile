# `make` is `init` = functions like /etc/inid.d - just in Makefile form

# 		Idea is `make` is ENTRYPOINT in OCI container, so CMD can be the make target
# 		with the "service" being a .PHONY target.  The nifty part is "arguments",
#       say some PORT=1883 needed by a service, can be provided EITHER using:
#            /container set [find] cmd="mqtt MQTT_PORT=1883"
# .     or...
# .          /container/env add

# 		Goal is to more easily, and safely, enable **running** multiple process at startup
# 		inside a RouterOS container, which is pretty different environment from most "Dockers"

#       But this is an experiment - thus the extra commentary here.

# If no C/C++/etc code, disable the automatic handling of `cc`/etc which clutters logs
.SUFFIXES:

# .PHONY is critical!  All targets should have a coorsponding .PHONY listed.
# Otherwise, the target is assumed to produce a file, which is going to fail in "make".
.PHONY: loop

# DEFAULT MODE - keep container running, without any services services
# In most cases, /container should cmd="run" (which is Dockerfile default)
# but an empty cmd= will use 'loop' recipe to allow /terminal/shell.
loop:
	/bin/sh -c "while :; do sleep 3600; done"
# 		this prevents make from existing, and allows /container/shell access
# 		essentially same as "tail -f /dev/null" in Docker-terms

# IMPORTANT: all paths used must be FULLY QUALIFIED - do not expect PATH to work in any target
#    i.e. sett above that /bin/sh is used.


# HOW IT WORK: "services", which are make .PHONY targets, live in the "make.d" directory.
#  So, the next thing to do is process that directory and "include" them.

# In order to make writing a Makefile make.d script (ending in .mk) easier...
# Define some helper functions that can be used like:
#

# Now... look to the make.d to add potential services

# In make.d, the _files.mk are specifically processed FIRST here, and in a explicit order
# so that "regular services" can use functions and depend on "_system services".
# make's include directive essentially insert a file into this file

# _make.mk loads first to provide helpers to all other services
include ./make.d/_make.mk

# add Desktop Docker targets for run and build
# todo: exclude when not actually running on docker
include ./make.d/_docker.mk

# add *.mk files from make.d so there usable via cmd=
initd_mk_files := $(wildcard ./make.d/*.mk)
initd_mk_files := $(filter-out ./make.d/_%.mk, $(initd_mk_files))
include $(initd_mk_files)

# finally the Dockerfile's default cmd=run ...
# this uses SERVICES= to control which recipes (from make.d to _actually_ start )
.PHONY: run
# The "run" target has a dependency on the list $(SERVICES) var provided from container.
# Each services listed in $(SERVICES) is then "run", using make's builtin parallelization (make -J #)
# This is essentially what triggers the build
# 		Variables can be provided via CMD in form "VAR=myval" or via /container/env
# 		This uses Makefile's ?= syntax, which sets default value - if one was NOT provided by else
# If not services set, enable  "syslogd" and "sshd"
# The list of services to automatically start is a variable SERVICES.
SERVICES ?= syslogd sshd http
run: $(SERVICES)
	$(info make.init terminating - this may be unexpected)