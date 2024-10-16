## ** EXTRA TOOLS **
# > non-essential, or less frequently used tools not included in base make.d

.PHONY: all-extras 
all-extras: openapi-tui nmap systeroid

.PHONY: openapi-tui
openapi-tui:
ifeq ($(UNAME_MACHINE),armv7l)
	$(warning "Skipping openapi-tui on armhf architecture")
else
	$(call apk_add, openapi-tui)
endif 

.PHONY: nmap
nmap:
	$(call apk_add, nmap nmap-doc)

.PHONY: systeroid
systeroid:
	$(call apk_add, systeroid systeroid systeroid-tui systeroid-tui-doc)

# note: example of building rust using cargo, and removing rust build after 
.PHONY: cute-tui
cute-tui: /usr/local/bin/cute

.PRECIOUS: /usr/local/bin/cute 
/usr/local/bin/cute:       
	$(call build_apk_addgroup, .cargo-cute-tui, rust cargo openssl openssl-dev)
	cargo install CuTE-tui                                                
	cp ~/.cargo/bin/cute /usr/local/bin      
	$(call build_apk_cleanup, .cargo-cute-tui)
