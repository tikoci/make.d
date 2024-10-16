## *** RUNTIME ***
# > Various programming langauage runtimes and interpreters, often dependancies for real recipes.

.PHONY: all-runtimes
all-runtimes: build-core golang nodejs python3 erlang ruby crystal

.PHONY: nodejs
nodejs: /usr/bin/node
.PRECIOUS: /usr/bin/node
/usr/bin/node:
	$(call apk_add, nodejs nodejs-doc npm npm-doc yarn)

.PHONY: golang
golang: /usr/bin/go
.PRECIOUS: /usr/bin/go
/usr/bin/go:
	$(call apk_add, go go-doc)
# unneeded now, but examples of adding more packages if go needs to be installed
#	GOBIN=/usr/local/bin go install github.com/goreleaser/goreleaser@latest
#	GOBIN=/usr/local/bin go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

.PHONY: python3 
python3: /usr/bin/python3
.PRECIOUS: /usr/bin/python3
/usr/bin/python3: 
	$(call apk_add, python3 python3-doc py3-pip py3-pip-bash-completion py3-pip-doc)

.PHONY: rust
rust: 
	$(call apk_add, rust cargo openssl openssl-dev)

.PHONY: erlang 
# also inlcudes elixir and gleam
erlang:
	$(call apk_add, erlang erlang-doc rebar3 elixir elixir-doc gleam)

.PHONY: ruby 
ruby:
	$(call apk_add, ruby ruby-doc ruby-rake ruby-rake-doc)

.PHONY: crystal
crystal:
	$(call apk_add, crystal crystal-bash-completion crystal-doc)

.PHONY: build-core 
build-core:
	$(call app_add, build-base linux-headers alpine-sdk) 

# NOTE: This crashes ENTIRE Docker Desktop with error never seen (and restarts everything).
#       Was trying to build Eralng like it's image does for lorawan-server (since Alpine's erlang is too new)

#.PHONY: erlang-manual
#erlang-manual:
#	OTP_VERSION="27.1.1" \
#    REBAR3_VERSION="3.23.0" \
#	set -xe \
#	&& OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-$${OTP_VERSION}.tar.gz" \
#	&& OTP_DOWNLOAD_SHA256="315552992ebbc86f27b54b4267616ad49b10fa2ef6bc4ec2a6992f7054c9157e" \
#	&& REBAR3_DOWNLOAD_SHA256="00646b692762ffd340560e8f16486dbda840e1546749ee5a7f58feeb77e7b516" \
#	&& apk add --no-cache --virtual .fetch-deps \
#		curl \
#		ca-certificates \
#	&& curl -fSL -o otp-src.tar.gz "$$OTP_DOWNLOAD_URL" \
#	&& echo "$$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
#	&& apk add --no-cache --virtual .build-deps \
#		dpkg-dev dpkg \
#		gcc \
#		g++ \
#		libc-dev \
#		linux-headers \
#		make \
#		autoconf \
#		ncurses-dev \
#		openssl-dev \
#		unixodbc-dev \
#		lksctp-tools-dev \
#		tar \
#	&& export ERL_TOP="/usr/src/otp_src_$${OTP_VERSION%%@*}" \
#	&& mkdir -vp $$ERL_TOP \
#	&& tar -xzf otp-src.tar.gz -C $$ERL_TOP --strip-components=1 \
#	&& rm otp-src.tar.gz \
#	&& ( cd $$ERL_TOP \
#	  && ./otp_build autoconf \
#	  && gnuArch="$(dpkg-architecture --query DEB_HOST_GNU_TYPE)" \
#	  && ./configure --build="$$gnuArch" \
#	  && make -j$(getconf _NPROCESSORS_ONLN) \
#	  && make install ) \
#	&& rm -rf $$ERL_TOP \
#	&& find /usr/local -regex '/usr/local/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\)' | xargs rm -rf \
#	&& find /usr/local -name src | xargs -r find | grep -v '\.hrl$$' | xargs rm -v || true \
#	&& find /usr/local -name src | xargs -r find | xargs rmdir -vp || true \
#	&& scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
#	&& scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
#	&& runDeps="$$( \
#		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
#			| tr ',' '\n' \
#			| sort -u \
#			| awk 'system("[ -e /usr/local/lib/" $$1 " ]") == 0 { next } { print "so:" $$1 }' \
#	)" \
#	&& REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/$${REBAR3_VERSION}.tar.gz" \
#	&& curl -fSL -o rebar3-src.tar.gz "$$REBAR3_DOWNLOAD_URL" \
#	&& echo "$${REBAR3_DOWNLOAD_SHA256}  rebar3-src.tar.gz" | sha256sum -c - \
#	&& mkdir -p /usr/src/rebar3-src \
#	&& tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
#	&& rm rebar3-src.tar.gz \
#	&& cd /usr/src/rebar3-src \
#	&& HOME=$$PWD ./bootstrap \
#	&& install -v ./rebar3 /usr/local/bin/ \
#	&& rm -rf /usr/src/rebar3-src \
#	&& apk add --virtual .erlang-rundeps \
#		$$runDeps \
#		lksctp-tools \
#		ca-certificates \
#	&& apk del .fetch-deps .build-deps 