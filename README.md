> **NOTE**
>  This is an experimental concept.  Not for production use.
>  _Even this README is a work in progress._

```
define etc_motd
> make.d 0.1.167 alpha

███╗   ███╗ █████╗ ██╗  ██╗███████╗   ██████╗
████╗ ████║██╔══██╗██║ ██╔╝██╔════╝   ██╔══██╗
██╔████╔██║███████║█████╔╝ █████╗     ██║  ██║
██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝     ██║  ██║
██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██╗██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝


Curated Alpine Linux tools and services to work with RouterOS.

Using `/container/shell`...
  More tools can be added using `mk <recipe>`.
  Using `bash`, hit TAB twice after `mk` shows recipes to make.
  Most configuration is stored under `/app`, use `edit <file>`.
  The default `nano` editor supports basic colors and syntax checks.

For services "daemons", make.d uses `/app/Makefile` to run them
  Daemons are just "build targets", provided as `cmd=` to `/container`
  e.g.  `/container add tag="ammo74/make.d" cmd="midimonster mqtt"`,
  make.d relies on `make`'s parallelization & "reaping" to run them both

See https://github.com/tikoci/make.d for the latest info.
For help, use `mk help` or `mk commentary` for release notes.
Linux man pages are also available: `man <command>` or `man -k <topic>`

endef
```

## make.d Container

_RouterOS container setup and general usage are not covered._

To bring up make.d, use `/container add tag="ammo74/make.d"` with VETH that allows
outbound internet, and any ports "exposed" by any service _recipes_ allowed inbound
is what's required.  The specific config beyond that is highly dependent on use cases.

By default, make.d brings up `syslogd`, `lighttpd`, and Dropbear `sshd` if **nothing** is set
in `cmd=` nor `entrypoint=` (and no env's).  A webpage will shown on port 80, 
and one non-root user `sysop` (_password_ `changeme`) for use with SSH.

To run no services, set make.d container's `cmd=loop`.  This is useful for experimenting,
since `/container/shell` allows access to make.d as `root` to run things.  

> Since `make` is the entrypoint, `cmd` is assumed to be a target in `/app/Makefile`.
> By design, if `make` exits, the container stops as the prevents errors from going unnoticed –
> `make` should succeed, or be waiting on some process to exit - just like default Alpine.
> So `loop` is a special target to keep `make /app/Makefile` waiting, on nothing. 
> `run` is also a special target, that is `Dockerfile` default `cmd=`, and uses
> a `SERVICES` env var to read the list of services (as an alternative to modifying `cmd=`)
> If `SERVICES` is not set in `/container/env` for make.d, then `Makefile` will use
> a default value of "syslogd sshd http" — which is how the default config works.

## About make.d Framework

make.d is more a simple layer over Alpine's APK packages, than a new container.  
Alpine has many packages, but not all are as regularized as other distros.
So one fundamental _opinion_ is all configuration should like under `/app`,
with configuration following through environment variables - not files.
The other make.d framework principal is all "scripting" flow through a `Makefile`,
to organize "shell code" than a bunch of `*.sh` files everywhere - leveraging `make`'s
ability along with, now unwritten, conventions.

> Also, nothing is RouterOS-specific other than perhaps packages and a few recipes.
> The author's specific needs however are RouterOS /containers, thus the focus.  

## make.d Recipes

Recipes are invoked using `mk` in `/container/shell`, or in `cmd=` to run at startup.  The recipes 
are stored in `/app/make.d/*.mk`, and loaded by `/app/Makefile`.  

> In the shell, the `mk` command is added by make.d, wraps `make -f /app/Makefile`, 
> to `make` can be called from **any directory**, and `mk` args are passed directly to
> `/app/Makefile`.  So `mk`'s options match `man make`.  


A specific list is
shown using `mk `<kbd>tab</kbd><kbd>tab</kbd>:

```
all-databases            help                     play-games
all-extras               help-job-control         play-mines
all-games                help-update              play-snake
all-help                 http                     pocketbase
all-mail                 imap                     postgres
all-runtimes             install-all-tools        pqsl
all-serial               librouteros              python3
all-text                 librouteros-dev          redis
alpine-sdk               lighttpd                 ruby
asciidoc                 list-commands            run
bind9                    list-games               rust
blocky                   list-recipes             sqlite
build-core               loop                     sshd
check-for-updates        lorawan-server           stress-alls
commentary               midimonster              stress-build-go
crystal                  mosquitto                stress-build-linux
cute-tui                 mqtt                     stress-build-rust
dns                      netinstall               stress-everything
docker-build             newsboat                 stress-nobuild
docker-build-arm6        nmap                     stress-services
docker-build-arm64       node-red                 stress-services-build
docker-build-arm7        nodejs                   stress-services-nobuild
docker-build-x86         nodered                  syslogd
docker-run               nodered-update           systeroid
docker-shell             notes-container-use      telnetd
dovecot                  notes-future-fixes       texinfo             
```

Some recipes just install tools, like `mk python3` which will add python for use.
Other recipes might both install and run something, like `mk play-snake`, which also runs
`apk add bsdgames` to get `snake` into the container.


"Daemons" are called _service recipes_, which are typically network services like `bind9` 
or applications like `lighttpd`.  

Service recipes are designed to be used on the `cmd=`
to keep them running in the container.  For testing, shell job control can be used to
start services temporally from `/container/shell`.  For example, to start `mosquitto` MQTT broker,
using ampersand & after make means run in the background: `mk <service_recipe> &`.  `man bash`.
See `mk help-job-control` for details on shell job control.

As more a proof-of-concept, not services in make.d will work out-of-the-box, but
most were tacitly tested to start.  Check the code in /app/make.d/*.mk for
any services you plan to use – most have some rough commentary on status and/or usage. 
 _Some things may_ never _run on low mem/CPU devices - but that's not something anyone can fix_.  
 And various parts are half-based, like `/app` is a git repo, but nothing uses it.  And some
"recipes" only wrap `apk add`, but do not move the package's config under `/app`.


> In some cases, services can be compiled inside the /container if needed (albeit small things), 
> with `/app/make.d/midi.mk` as an example that loads tools to build, then
> compiles [`midimonster`](https://midimonster.net) for the architecture, and finally
> removes build tools to preserve disk space.  Internally, this uses `apk ... -virtual ...`.
> **More complex builds will crash most RouterOS devices**.  e.g. `mk cute-tui` (aka `mk stress-build-rust`) 
> which uses Rust's `cargo`, and `mk pocketbase` which uses `go` – both will crash a RB1100AHx4.
> A set of "stress-*" targets are offered by `mk`, like `mk stress-everything` if that's
> what you're looking to do.

