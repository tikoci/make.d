## ** EXTRA TOOLS **
# > non-essential, or less frequently used tools not included in base make.d

.PHONY: tools-extras
all-extras: tools-network tools-tuis tools-color tools-serial

.PHONY: tools-tuis
tools-tuis: add-systeroid add-helix add-openapi-tui add-trippy add-newsboat add-wiki-tui

.PHONY: add-wiki-tui
add-wiki-tui: /usr/bin/wiki-tui
.PRECIOUS: /usr/bin/wiki-tui
/usr/bin/wiki-tui:
	$(call apk_add_testing, wiki-tui wiki-tui-doc)


.PHONY: add-newsboat
add-newsboat: /app/newsboat/awesome-rss-feeds/README.md /usr/bin/newsboat
	$(shell mkdir -p /app/newsboat)
	$(file >/app/newsboat/urls,$(mikrotik_newsboat_urls))
	mkdir -p ~/.newsboat
	cp -n /app/newsboat/urls ~/.newsboat/urls
.PRECIOUS: /usr/bin/newsboat
/usr/bin/newsboat:
	$(call apk_add, newsboat newsboat-doc)

# keep a copy of _unloaded_ RSS for for use with 'newsboat -I <file>' to import
# feeds in _local_ users - Mikrotik URL are only default RSS feeds.
.PRECIOUS: /app/newsboat/awesome-rss-feeds/README.md
/app/newsboat/awesome-rss-feeds/README.md:
	$(shell mkdir -p /app/newsboat)
	wget https://github.com/plenaryapp/awesome-rss-feeds/archive/refs/heads/master.zip -O /app/newsboat/awesome-rss.zip
	unzip /app/newsboat/awesome-rss.zip -d /app/newsboat
	mv -f /app/newsboat/awesome-rss-feeds-master /app/newsboat/awesome-rss-feeds
	rm -f /app/newsboat/awesome-rss.zip

define mikrotik_newsboat_urls
https://mikrotik.com/current.rss mikrotik news "~Mikrotik Releases and News"
https://forum.mikrotik.com/feed.php?f=21 mikrotik news forum "~Mikrotik Forum - Announcements"
https://forum.mikrotik.com/feed.php?f=23 mikrotik forum "~Mikrotik Forum - Useful user articles"
https://forum.mikrotik.com/feed.php?f=2 mikrotik forum "~Mikrotik Forum - General"
https://forum.mikrotik.com/feed.php?f=24 mikrotik forum "~Mikrotik Forum - Containers"
https://forum.mikrotik.com/feed.php?f=25 mikrotik forum "~Mikrotik Forum - 3rd party tools"
https://forum.mikrotik.com/feed.php?f=9 mikrotik forum "~Mikrotik Forum - Scripting "
https://forum.mikrotik.com/feed.php?f=8 mikrotik forum "~Mikrotik Forum - The Dude"
https://forum.mikrotik.com/feed.php?f=10 mikrotik forum "~Mikrotik Forum - The User Manager"
https://forum.mikrotik.com/feed.php?f=15 mikrotik forum "~Mikrotik Forum - Virtualization"
endef

.PHONY: add-systeroid
add-systeroid: /usr/bin/systeroid
.PRECIOUS: /usr/bin/systeroid
/usr/bin/systeroid:
	$(call apk_add, systeroid systeroid systeroid-tui systeroid-tui-doc)

.PHONY: add-trippy
add-trippy: /usr/bin/trip
.PRECIOUS: /usr/bin/trip
/usr/bin/trip:
	$(call apk_add_testing, trippy trippy-bash-completion)

# note: example of building rust using cargo, and removing rust build after
.PHONY: add-cute-tui
add-cute-tui: /usr/local/bin/cute
.PRECIOUS: /usr/local/bin/cute
/usr/local/bin/cute:
	$(warning CuTE-tui uses rust/cargo to build it self - this is too much on RB1100, likely any armv7 system)
	$(call build_apk_addgroup, .cargo-cute-tui, rust cargo openssl openssl-dev)
	cargo install CuTE-tui
	cp ~/.cargo/bin/cute /usr/local/bin
	$(call build_apk_cleanup, .cargo-cute-tui)

# Makefile linter - requires cargo
.PHONY: add-unmake
add-unmake: /usr/local/bin/unmake
.PRECIOUS: /usr/local/bin/unmake
/usr/local/bin/unmake:
	$(call build_apk_addgroup, .cargo-unmake, rust cargo)
	cargo install unmake
	cp ~/.cargo/bin/unmake /usr/local/bin
	$(call build_apk_cleanup, .cargo-unmake)

# todo: add schmea from: https://tikoci.github.io/restraml/...
#       problem is OAS3 works better...

.PHONY: add-openapi-tui
add-openapi-tui:
ifeq (,$(findstring armv,$(UNAME_MACHINE)))
	$(call apk_add_testing, openapi-tui)
else
	$(warning "Skipping openapi-tui on armhf architecture")
endif

# schemas

#### Rust TUIs reviewed but not included:
### interesting but require cargo install 
# atac # 
# sshs # TUI saved ssh session to pick
# netop (+libpcap-dev) # network monitoring
# grex # regex "helper"
### broken/less potentially useful
# zenith # monitoring but crashes due to "battery" (Alpine has no ACPI nor sys... things for it) 
# topgrade # upgrade/version checking - does little
# erldash	# likely works, but need erlang - moved to install with erlang
# 
