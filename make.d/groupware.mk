## ** MAIL **
# > lightweight "mail stack" for M2M, not end-users - POP3/IMAP/SMTP

# NOTE: these are stubs that installs the packages, no curation or start yet

.PHONY: tools-mail
tools-mail: add-exim add-imap add-goimapnotify add-mailtutan
	$(warning mail recipes just install packages)

.PHONY: add-exim
# todo: use /app and start...
add-exim:
	$(warning mail recipes just install packages)
	$(call apk_add, exim)

.PHONY: add-dovecot
# note: not part of all-mail - will try old/simpler UW ver
# todo: use /app and start...
add-dovecot:
	$(warning mail recipes just install packages)
	$(call apk_add, dovecot)

.PHONY: add-imap
# todo: use /app and start...
add-imap:
	$(warning mail recipes just install packages)
	$(call apk_add, imap)

.PHONY: add-goimapnotify
# todo: use /app and start...
add-goimapnotify:
# untested... need IMAP working first
# perhaps simplier alternative to exim to connect mail to scripts 
	$(warning mail recipes just install packages)
	$(call apk_add, goimapnotify)


.PHONY: add-mailtutan mailtutan-test
# note: it does not seem to work with routeros, auth is messed up somewhere
#       and idea was not use auth since it really for IPC to routeros
add-mailtutan:
	$(call apk_add_testing, mailtutan)
mailtutan-test: add-mailtutan
	$(shell mkdir -p /app/mailtutan/maildirs) 
	mailtutan \
	--http-port 1025 \
	--smtp-port 25 \
	--smtp-cert-path /app/.ssh/maked.cert \
	--smtp-key-path /app/.ssh/maked.key \
	--smtp-auth-username mail \
	--smtp-auth-password mail \
	--maildir-path /app/mailtutan/maildirs \
	--storage maildir

