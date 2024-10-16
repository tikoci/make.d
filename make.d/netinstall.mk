## ** NETINSTALL **
# > Most interesting, recurisive "make.d" 

# NOTE: this download the ammo74/netinstall Makefile, and use $(MAKE) which calls another Makefile

.PHONY: netinstall

# from: https://github.com/tikoci/netinstall/pull/5
NETINSTALL_MAKEFILE_URL ?= https://raw.githubusercontent.com/tikoci/netinstall/refs/heads/master/Makefile
# NETINSTALL_MAKEFILE_URL ?= https://raw.githubusercontent.com/clorichel/netinstall/refs/heads/patch-1/Makefile
netinstall:
	$(shell mkdir -p /app/netinstall)
	$(shell wget $(NETINSTALL_MAKEFILE_URL) -O /app/netinstall/Makefile)
	cd /app/netinstall && $(MAKE) -j 16 -f /app/netinstall/Makefile 
