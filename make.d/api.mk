
.PHONY: add-librouteros
add-librouteros: /usr/local/src/librouteros-api/librouteros.so /app/librouteros/README.md 
	mkdir -p /app/librouteros

.PHONY: add-librouteros-dev
add-librouteros-dev: add-alpine-sdk /usr/local/src/librouteros-api/librouteros.so
	$(shell mkdir -p /app/librouteros/src)
	$(shell ln -s /usr/local/src/librouteros-api /app/librouteros/libsrc)
	$(shell cp -n /usr/local/src/librouteros-api/examples/cmd.c /app/librouteros/src/roscmd.c)
	$(shell cp -n /usr/local/src/librouteros-api/examples/cancel.c /app/librouteros/src/roscancel.c)
	$(shell sed -i 's|#include "../librouteros.h"|#include <librouteros.h>|' /app/librouteros/src/*.c)
	$(file >/app/librouteros/src/Makefile, $(librouteros_src_makefile))
	$(file >/app/librouteros/Makefile, $(librouteros_makefile))
	$(MAKE) -C /app/librouteros

.PRECIOUS: /app/librouteros/README.md
/app/librouteros/README.md: 
	$(shell mkdir -p /app/librouteros)
	$(file >/app/librouteros/README.md, $(librouteros_readme))

## note: this copies the librouteros-api from /usr/local/src to /app/librouteros
##       in a slightly refactored form to make it easier to create new small API apps
#.PRECIOUS: /app/librouteros/OLD_README.md
#/app/librouteros/OLD_README.md: /usr/local/src/librouteros-api/librouteros.so
#	$(shell mkdir -p /app/librouteros)
#	$(shell mkdir -p /app/librouteros/src)
#	$(shell mkdir -p /app/librouteros/lib)
#	$(shell mkdir -p /app/librouteros/lib/examples)
#	$(shell mkdir -p /app/librouteros/bin)
#	cp /usr/local/src/librouteros-api/*.c /app/librouteros/lib
#	cp /usr/local/src/librouteros-api/*.h /app/librouteros/lib
#	cp /usr/local/src/librouteros-api/examples/* /app/librouteros/lib/examples
#	$(file >/app/librouteros/README.md, $(librouteros_readme))
#	$(file >/app/librouteros/Makefile, $(librouteros_makefile))
#	$(file >/app/librouteros/lib/Makefile, $(librouteros_lib_makefile))
#	$(file >/app/librouteros/lib/examples/Makefile, $(librouteros_lib_makefile))
#	$(file >/app/librouteros/src/Makefile, $(librouteros_src_makefile))
#	$(file >/app/librouteros/src/test.c, $(:librouteros_src_test_c))
#	wget https://raw.githubusercontent.com/github/gitignore/refs/heads/main/C.gitignore -O /app/librouteros/.gitignore
#	git add .
#	git commit -m "make.d librouteros-lib defaults from `date`"

.PRECIOUS: /usr/local/src/librouteros-api/librouteros.so
/usr/local/src/librouteros-api/librouteros.so: add-git
	mkdir -p /usr/local/src/librouteros-api
	git clone https://github.com/gjalves/librouteros-api.git /usr/local/src/librouteros-api
	$(call build_apk_addgroup, .librouteros-build, alpine-sdk)
	$(MAKE) -C /usr/local/src/librouteros-api clean
	$(MAKE) -C /usr/local/src/librouteros-api
	$(MAKE) -C /usr/local/src/librouteros-api install
	$(call build_apk_cleanup, .librouteros-build, alpine-sdk)


define librouteros_readme

## RouterOS API C library and examples

`/app/librouteros can be used to build Alpine's toolchain "apps", including within /container.

> **This is work in progress.**

Generally speaking using REST and `curl` is a better plan.
But idea is have the C RouterOS API library available in make.d
to make it easier to use RouterOS API's **listen** action,
since `curl` and RouterOS REST API are limited to polling,
or waiting a max 60 seconds.  The native API allow streaming.

See https://help.mikrotik.com/docs/spaces/ROS/pages/47579160/API


## Creating C RouterOS API apps

To write your own code using the librouteros-api C libs, use
`mk librouteros-dev` which DOES install the linux toolchains needed,
and will add Makefile and more in this directory.

The `./src` is where you can your own C-based code.
To build, just run `make` in /app/librouteros. This will [re-]compile the
shared `librouteros.so` and run the `/app/librouteros/src/Makefile` .

## librouteros vs librouteros-dev

The RouterOS C library is installed via `mk librouteros`,
without any compiler tools being permanently installed,
this keeps disk space small once something has be compiled.

But for development, the GNU toolchain is needed - which is 50M or more.
The tools are installed automatically by `mk librouteros-dev`.  
But, once you have complied a project, the toolchain is not needed to run your executable 
and the toolchain can be removed (and/or re-added if needed) manually via:
 `apk [add/del] alpine-sdk`, which includes most Linux build tools, including GNU.

> `librouteros.so` comes from:
> https://github.com/gjalves/librouteros-api
> which is based on https://github.com/haakonnessjoen/librouteros-api
> The original source code is in /usr/local/src/librouteros-api

endef

# note: macro used in Makefile generation below, so all have same options
librouteros_cflags = -v -I/usr/include -fPIC -Wall -Wextra -O2

# note: $ have to be escaped, like $$ to be in a define
#       but real file will use $ as make expects

define librouteros_makefile
.PHONY: all install clean

all:
	$$(MAKE) -C ./libsrc
	$$(MAKE) -C ./src

install:
	$$(MAKE) -C ./libsrc install
	$$(MAKE) -C ./src install

clean:
	$$(MAKE) -C ./libsrc clean
	$$(MAKE) -C ./src clean

endef


define librouteros_lib_makefile
CFLAGS = $(librouteros_cflags)
LDFLAGS = -shared

.PHONY: all
all: librouteros.so

librouteros.o: librouteros.c
md5.o: md5.c

librouteros.so: librouteros.o md5.o
	$$(CC) $$(CFLAGS) $$(LDFLAGS) -o $$@ $$<

.PHONY: install
install:
	cp librouteros.so /usr/local/lib/librouteros.so

.PHONY: clean
clean:
	rm -f *.so *.o *.a
endef

define librouteros_src_makefile

TARGETS = roscmd roscancel
CFLAGS = $(librouteros_cflags)
LDFLAGS = -L/usr/lib -lrouteros

.PHONY: all
all: $$(TARGETS)

roscmd: roscmd.c
	$$(CC) $$(CFLAGS) -o $$@ $$< $$(LDFLAGS)

roscancel: roscancel.c
	$$(CC) $$(CFLAGS) -o $$@ $$< $$(LDFLAGS)

.PHONY: install

install: $$(TARGETS)
	cp $$(TARGETS) /usr/local/bin

.PHONY: clean
clean:
	rm -f *.so *.o *.a $$(TARGETS)

endef
