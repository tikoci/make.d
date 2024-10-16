## ** TEXT **
# > editors and text processing tools like texinfo and pandoc

.PHONY: all-text
all-text: vim emacs newsboat wikitui texinfo asciidoc pandoc
	$(warning pandoc and texinfo are kinda big...)
	$(info text recipes just install packages)

.PHONY: vim
vim:
	$(call apk_add, vim vim-doc)

.PHONY: emacs
emacs:
	$(call apk_add, emacs emacs-doc)

.PHONY: wikitui
wikitui:
	$(call apk_add_testing, wiki-tui wiki-tui-doc)
	
.PHONY: texinfo 
texinfo:
	$(call apk_add, texinfo texinfo-doc )

.PHONY: asciidoc
asciidoc:
	$(call apk_add, asciidoc asciidoc-doc)

.PHONY: pandoc 
pandoc: asciidoc texinfo
	$(call apk_add, pandoc-cli)

.PHONY: newsboat
newsboat: /app/newsboat/awesome-rss-feeds/README.md
	$(call apk_add, newsboat newsboat-doc)
	$(shell mkdir -p /app/newsboat)
	$(file >/app/newsboat/urls,$(mikrotik_newsboat_urls))
	mkdir -p ~/.newsboat 
	cp -n /app/newsboat/urls ~/.newsboat/urls

# keep a copy of _unloaded_ RSS for for use with 'newsboat -I <file>' to import
# feeds in _local_ users - Mikrotik URL are only default RSS feeds.
.PRECIOUS: /app/newsboat/awesome-rss-feeds/README.md
/app/newsboat/awesome-rss-feeds/README.md:
	$(shell mkdir -p /app/newsboat/awesome-rss-feeds)
	wget https://github.com/plenaryapp/awesome-rss-feeds/archive/refs/heads/master.zip -O /app/newsboat/awesome-rss.zip
	unzip /app/newsboat/awesome-rss.zip -d /app/newsboat 
	mv /app/newsboat/awesome-rss-feeds-master /app/newsboat/awesome-rss-feeds
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
