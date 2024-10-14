## ** MAIL **
# > lightweight "mail stack" for M2M, not end-users - POP3/IMAP/SMTP

# NOTE: these are stubs that installs the packages, no curation or start yet

.PHONY: all-mail
all-mail: exim imap goimapnotify
	$(warning mail recipes just install packages)

.PHONY: exim
# todo: use /app and start...
exim:
	$(call apk_add, exim)

.PHONY: dovecot
# note: not part of all-mail - will try old/simpler UW ver
# todo: use /app and start...
dovecot:
	$(call apk_add, dovecot)

.PHONY: imap
# todo: use /app and start...
imap: 
	$(call apk_add, imap imap-doc)

.PHONY: goimapnotify 
goimapnotify:
# todo: use /app (and start?)
# untested... need IMAP working first, but purpored simplier IMAP listener
	$(call apk_add, goimapnotify)

