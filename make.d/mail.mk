## ** MAIL **
# > lightweight "mail stack" for M2M, not end-users - POP3/IMAP/SMTP

# NOTE: these are stubs that installs the packages, no curation or start yet

.PHONY: all-mail
all-mail: exim imap goimapnotify
	$(warning mail recipes just install packages)

.PHONY: exim
# todo: use /app and start...
exim:
	$(warning mail recipes just install packages)
	$(call apk_add, exim)

.PHONY: dovecot
# note: not part of all-mail - will try old/simpler UW ver
# todo: use /app and start...
dovecot:
	$(warning mail recipes just install packages)
	$(call apk_add, dovecot)

.PHONY: imap
# todo: use /app and start...
imap: 
	$(warning mail recipes just install packages)
	$(call apk_add, imap)

.PHONY: goimapnotify 
goimapnotify:
# todo: use /app (and start?)
# untested... need IMAP working first, but purpored simplier IMAP listener
	$(warning mail recipes just install packages)
	$(call apk_add, goimapnotify)

