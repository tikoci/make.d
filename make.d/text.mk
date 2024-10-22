## ** TEXT **
# > editors and text processing tools like texinfo and pandoc

.PHONY: tools-all-text
tools-all-text: tools-editors tools-docs tools-color
	$(warning pandoc and texinfo are kinda big...)
	$(info text recipes just install packages)

.PHONY: tools-editors
tools-editors: add-vim add-emacs add-helix tools-color

.PHONY: tools-docs
tools-docs: add-texinfo add-asciidoc add-pandoc add-mdbook tools-color

.PHONY: add-vim
add-vim:
	$(call apk_add, vim vim-doc)

.PHONY: add-emacs
add-emacs:
	$(call apk_add, emacs emacs-doc)

# helix editor - lightweight vi with colors + tree-sitter
.PHONY: add-helix
add-helix: /usr/bin/hx
.PRECIOUS: /usr/bin/hx
/usr/bin/hx: add-tree-sitter
	$(call apk_add_testing, helix)

.PHONY: add-tree-sitter
add-tree-sitter:
#	add-tree-sitter seems broken
	$(call apk_add, tree-sitter tree-sitter-bash tree-sitter-c tree-sitter-cmake tree-sitter-comment tree-sitter-cpp tree-sitter-css tree-sitter-go tree-sitter-go-mod tree-sitter-html tree-sitter-ini tree-sitter-javascript tree-sitter-jsdoc tree-sitter-json tree-sitter-lua tree-sitter-python tree-sitter-regex tree-sitter-ruby tree-sitter-rust tree-sitter-static tree-sitter-toml tree-sitter-typescript)

.PHONY: add-texinfo
add-texinfo:
	$(call apk_add, texinfo texinfo-doc )

.PHONY: add-asciidoc
add-asciidoc:
	$(call apk_add, asciidoc asciidoc-doc)

.PHONY: add-pandoc
add-pandoc: add-asciidoc add-texinfo
	$(call apk_add, pandoc-cli)

.PHONY: add-mdbook
add-mdbook: /usr/bin/mdbook /app/mdbook/book.toml
	$(info mdbook for manpages use `mk mdbook-man` - but takes a long while since it builds rust)
.PRECIOUS: /app/mdbook/book.toml
/app/mdbook/book.toml: /usr/bin/mdbook
	/usr/bin/mdbook init /app/mdbook --title "make.d" --ignore git
	/usr/bin/mdbook build /app/mdbook
.PHONY: add-mdbook-man
add-mdbook-man: /usr/bin/mdbook /usr/local/bin/mdbook-man
.PRECIOUS: /usr/bin/mdbook
/usr/bin/mdbook:
	$(call apk_add, mdbook)
/usr/local/bin/mdbook-man: /usr/bin/mdbook
	$(call build_apk_addgroup, .mdbook-man, cargo)
	cargo install mdbook-man
	cp /root/.cargo/mdbook-man $@
	$(call build_apk_cleanup, .mdbook-man, cargo)


# metapackage "colorized" tools for cat/less printing of formatted files
.PHONY: tools-color
tools-color: /usr/bin/bat /usr/bin/jless /usr/bin/mdless
# colorized cat
.PRECIOUS: /usr/bin/bat
/usr/bin/bat:
	$(call apk_add, bat)
# colorized json cat
.PRECIOUS: /usr/bin/jless
/usr/bin/jless:
	$(call apk_add, jless)
# colorized md cat
.PRECIOUS: /usr/bin/mdless
/usr/bin/mdless:
	$(call apk_add_testing, mdcat)
.PRECIOUS: /usr/bin/mdcat
/usr/bin/mdcat: /usr/bin/mdless
	$(call apk_add_testing, mdcat)
