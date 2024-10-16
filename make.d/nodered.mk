## ** NODERED **
# > Not sure it's category, so it get it own for now 


.PHONY: node-red
NODERED_OPTS ?= 
nodered: /usr/local/bin/node-red
	mkdir -p /app/node-red
	node-red --userDir /app/node-red $(NODERED_OPTS)

/usr/local/bin/node-red: /usr/bin/node
	npm install -g --unsafe-perm node-red

.PHONY: nodered-update 
nodered-update:
	npm update
	npm upgrade node-red
