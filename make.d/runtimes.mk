## *** RUNTIME ***
# > Various programming langauage runtimes and interpreters, often dependancies for real recipes.

.PHONY: all-runtimes
all-runtimes: apks-build-base golang nodejs python3 erlang ruby crystal

.PHONY: nodejs 
nodejs:
	$(call apk_add, nodejs nodejs-doc npm npm-doc yarn)
/usr/bin/node: nodejs

.PHONY: golang
golang:
	$(call apk_add, go go-doc)
	GOBIN=/usr/local/bin go install github.com/goreleaser/goreleaser@latest
	GOBIN=/usr/local/bin go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
/usr/bin/go: golang

.PHONY: python3 
python3:
	$(call apk_add, python3 python3-doc)
	$(call apk_add, py3-pip py3-pip-bash-completion py3-pip-doc)
	$(call apk_add, py3-pyserial py3-pyserial-pyc)
/usr/bin/python3: python3

.PHONY: erlang 
# also inlcudes elixir and gleam
erlang:
	$(call apk_add, erlang erlang-doc elixir elixir-doc gleam)

.PHONY: ruby 
ruby:
	$(call apk_add, ruby ruby-doc ruby-rake ruby-rake-doc)

.PHONY: crystal
crystal:
	$(call apk_add, crystal crystal-bash-completion crystal-doc)

.PHONY: apks-build-base 
apks-build-base:
	$(call app_add, build-base linux-headers) 
