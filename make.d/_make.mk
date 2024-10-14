# *** _make.mk *** - The PID 1 of make.d 
# > ... but just runs first from /app/Makefile, mainly helpers

# ** apk_add function ** - _safely_ adds packages using Alpine's "apk add"
flock_apk_add = flock /var/lib/apk/db/lock apk add $(1) 
flock_apk_add_nocache = flock /var/lib/apk/db/lock apk add --no-cache $(1) 
apk_add = apk --wait 120 update && apk --wait 120 add $(1)
apk_add_testing = apk --wait 120 update && apk --wait 120 add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing $(1)
# note: flock check the package database is in-use & waits for it before continuing
apk_list_by_size = apk list -Iq | while read pkg; do apk info -s "$$pkg" | tac | tr '\n' ' ' | xargs | sed -e 's/\s//'; done | sort -h

.PHONY: check-for-updates
check-for-updates:
	$(info checking for upgrade)
	apk update
	apk info -U
	apk stats

.PHONY: upgrade
upgrade: check-for-updates
	$(info update starting)
	apk update
	apk upgrade


