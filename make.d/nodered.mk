## ** NODERED **
# > Not sure it's category, so it get it own for now


.PHONY: nodered
NODERED_OPTS ?=
nodered: add-nodered
	mkdir -p /app/node-red
	node-red --userDir /app/node-red $(NODERED_OPTS)

.PHONY: add-nodered
add-nodered: /usr/local/bin/node-red

/usr/local/bin/node-red: /usr/bin/node
	npm install -g --unsafe-perm node-red

.PHONY: nodered-update
nodered-update:
	npm update
	npm upgrade node-red
