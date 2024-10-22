## ** INETD **
# > ... not really /etc/inetd, but networking tools live here

.PHONY: sshd 
# "sshd" service target
DROPBEAR_SSHD_OPTS ?= -F -R -E
SSHD_OPTS ?= -D
sshd: /etc/ssh/ssh_host_rsa_key
	$(info dropbear sshd starting)
	/usr/sbin/sshd $(SSHD_OPTS)

.PRECIOUS: /etc/ssh/ssh_host_rsa_key
/etc/ssh/ssh_host_rsa_key:
	ssh-keygen -A

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

# todo: maybe old TCP tools could be installable