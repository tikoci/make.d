## ** NODERED **
# > Not sure it's category, so it get it own for now


.PHONY: nodered
NODERED_OPTS ?=
nodered: add-nodejs add-nodered
	mkdir -p /app/node-red
	node-red --userDir /app/node-red $(NODERED_OPTS)

.PHONY: add-nodered
add-nodered: add-nodejs /usr/local/bin/node-red

.PRECIOUS: /usr/local/bin/node-red
/usr/local/bin/node-red: add-nodejs
	npm install -g --unsafe-perm node-red

.PHONY: nodered-update
nodered-update: add-nodered
	npm update
	npm upgrade node-red
