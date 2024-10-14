## [unfinished] ** SERIAL **
# > tools for working with serial via TCP

# NOTE: these are stubs that installs the packages, no curation or start yet

.PHONY: all-serial 
all-serial: /usr/bin/socat /usr/bin/expect python3
	$(call apk_add, py3-pyserial py3-pyserial-pyc)

/usr/bin/socat:
	$(call apk_add, socat socat-doc)

/usr/bin/expect:
	$(call apk_add, expect expect-doc)




