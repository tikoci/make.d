## ** INETD **
# > ... not really /etc/inetd, but networking tools live here

.PHONY: sshd
# "sshd" service target
SSHD_OPTS ?= -F -R
sshd:
	$(info dropbear sshd starting)
	/usr/sbin/dropbear $(SSHD_OPTS) 

.PHONY: syslogd 
# "syslogd" service target
SYSLOGD_OPTS ?= -n -S -s 10000
syslogd:
	$(info syslogd starting)
	/sbin/syslogd $(SYSLOGD_OPTS)

.PHONY: telnetd
TELNETD_OPTS ?= -p 23 -b 0.0.0.0 -l /bin/login -F
telnetd:
	$(info telnetd starting)
	/usr/sbin/telnetd $(TELNETD_OPTS)

.PHONY: nmap
nmap:
	$(call apk_add, nmap nmap-doc)

.PHONY: systeroid
systeroid:
	$(call apk_add, systeroid systeroid systeroid-tui systeroid-tui-doc)