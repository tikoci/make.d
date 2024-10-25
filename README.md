> **NOTE**
>  This is an experimental concept.  Not for production use.
>  _Even this README is a work in progress._

```
> make.d 0.1.174 alpha

███╗   ███╗ █████╗ ██╗  ██╗███████╗   ██████╗
████╗ ████║██╔══██╗██║ ██╔╝██╔════╝   ██╔══██╗
██╔████╔██║███████║█████╔╝ █████╗     ██║  ██║
██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝     ██║  ██║
██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██╗██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝

Curated Alpine Linux tools and services to work with RouterOS.
```

## make.d Container

_RouterOS container setup and general usage are not covered._

To bring up make.d, use `/container add tag="ammo74/make.d"` with VETH that allows
outbound internet, and any ports "exposed" by any service _recipes_ allowed inbound
is what's required.  The specific config beyond that is highly dependent on use cases.

By default, make.d brings up `lighttpd`, and `sshd` if **nothing** is set
in `cmd=` nor `entrypoint=` (and no env's).  A webpage will shown on port 80, 
and one non-root user `sysop` (_password_ `changeme`) for use with SSH.

To run no services, set make.d container's `cmd=loop`.  This is useful for experimenting,
since `/container/shell` allows access to make.d as `root` to run things.  

> **_Internals:_ Startup**
> 
> Since `make` is the entrypoint, `cmd` is assumed to be a target in `/app/Makefile`.
> By design, if `make` exits, the container stops as the prevents errors from going unnoticed –
> `make` should succeed, or be waiting on some process to exit - just like default Alpine.
> So `loop` is a special target to keep `make /app/Makefile` waiting, on _nothing_. 
> `run` is also a special target, that is `Dockerfile` default `cmd=`, and uses
> a `SERVICES` env var to read the list of services (as an alternative to modifying `cmd=`).
> If `SERVICES` is not set in `/container/env` for make.d, then Makefile` will use
> a default value of "sshd http" — which is how the default config works.  Changing
> either the env var, or cmd= is how you set what service you'd like to start. 

## About make.d Framework

make.d is more a simple "overlay" over Alpine's APK package management, than a new container.
In fact, just you can just `git clone` this repo into /app using a base Alpine container, 
and running `make` will do the same things as the `Dockerfile` just the same.

The idea behind make.d to be a semi-curated set of Alpine, for a variety of needs.
While Alpine simplicity is it's benifit, sometimes some cocktail of packages are needed
but the right `apk` and `vi` incantations are not always easy.

An additional feature of make.d is "meta packages", so `mk tools-network` will add a variety of 
networking tools like `dig` and `iperf3`, in one operation.  Also in the tool department, and for fun...
a variety of TUI-based interfaces are also available. Like [`mk add-newsboat`](https://newsboat.org) will install an TUI-based RSS reader, 
that can be started with `newsboat`, and comes preloaded by [`/app/make.d/extras.mk`](https://github.com/tikoci/make.d/blob/main/make.d/extras.mk) with various RouterOS RSS feeds.

One _opinion_ here is all configuration should like under `/app`,
ideally with configuration through environment variables - not files - for better automation.
The other make.d framework principal is all "scripting" flow through a `Makefile`,
which organizes all the "shell code" better than a bunch of `*.sh` files everywhere - leveraging `make`'s
ability along with some unwritten conventions to enable it.  Along those lines, even modified config is stored
in the Makefiles - rather than in seperate files.  With the idea being to force using tools (`sed`/`awk`/`patch`/`jq`/etc) 
to **modify** an existing configuration, than replacing files.


> Nothing here is RouterOS-specific.  A few recipes are,
> like librouteros-dev, which adds a lib for the RouterOS native API and mini-devkit in `/app/librouteros`,
> but none installed by "default". The author's specific needs however are RouterOS /containers,
> which is "unusual" container host.  But make.d work an "APK wrapper" on any Alpine-based installing,
> even outside containers – it's just a `Makefile` at the end of the day.  


## make.d Recipes

Recipes are invoked using `mk` in `/container/shell`, or in `cmd=` to run at startup.  The recipes 
are stored in `/app/make.d/*.mk`, and loaded by `/app/Makefile`.  

New receipes can be added by too, not quite "just copy-and-paste", but there are plenty of examples.
Any file ending in `*.mk`, will automatically be available as part of `mk` 
(and `make -C /app <target>`) just by being place in `/app/make.d`.

> In the shell, the `mk` command is added by make.d, but just wraps `make -C /app`, 
> to allow `make` being called from **any directory**, with any `mk` args are passed directly to
> `/app/Makefile`.  

A specific list of availble recipes can view either by using tab-completion `mk `<kbd>tab</kbd><kbd>tab</kbd>, 
or `mk list-recipes`:

```
add-alpine-sdk                  add-ruby                        netinstall
add-asciidoc                    add-rust                        nodered
add-aws-cli                     add-rustic                      nodered-update
add-bind9                       add-sox                         notes-building-new-recipes
add-blocky                      add-sqlite                      notes-container-use
add-build-core                  add-systeroid                   notes-future-recipes
add-caddy                       add-texinfo                     notes-open-issues
add-cloudflared                 add-traefik                     notes-tips
add-crystal                     add-tree-sitter                 play-atc
add-cute-tui                    add-trippy                      play-games
add-dovecot                     add-tsduck                      play-mines
add-emacs                       add-unmake                      play-snake
add-erlang                      add-vim                         pocketbase
add-erlang-tui                  add-wiki-tui                    postgres
add-exim                        all-extras                      run
add-ffmpeg                      all-help                        sshd
add-fossil                      bind9                           stress-build-src
add-git                         blocky                          stress-everything
add-goimapnotify                build-src                       stress-services
add-golang                      build-src-go                    stress-services-built
add-gstreamer                   build-src-linux                 stress-services-nobuild
add-helix                       build-src-rust                  stress-services-nobuild-unwise
add-imap                        caddy                           stress-subcommands
add-iperf3                      check-for-updates               syslogd
add-librouteros                 commentary                      telnetd
add-librouteros-dev             dns                             tools-all-langs
add-lighttpd                    fossil-init                     tools-all-text
add-lorawan-server              git-commit                      tools-all-vpns
add-lua53                       git-init                        tools-cloud
add-mailtutan                   help                            tools-color
add-mdbook                      help-job-control                tools-db
add-mdbook-man                  help-update                     tools-dns
add-midimonster                 http                            tools-docs
add-mosquitto                   install-all                     tools-editors
add-mtr                         install-all-built               tools-extras
add-newsboat                    install-all-services            tools-files
add-nmap                        install-all-tools               tools-games
add-nodejs                      install-everything              tools-mail
add-nodered                     lighttpd                        tools-music
add-openapi-tui                 list-commands                   tools-network
add-openvpn                     list-games                      tools-serial
add-pandoc                      list-recipes                    tools-tuis
add-pocketbase                  loop                            tools-video
add-postgres                    mailtutan-test                  tools-wireguard
add-pptpclient                  midimonster                     traefik
add-python3                     midimonster-drivers             upgrade
add-restic                      mosquitto                       
add-rsync                       mqtt                            
```

Some recipes just install tools, like `mk add-python3` which will add python for use.
Other recipes might both install and run something, like `mk play-snake`, which also runs
[`apk add bsdgames`](https://wiki.linuxquestions.org/wiki/BSD_games) to facilite "download on demand" for `snake`.
Others like `midimonster` and `mosquitto` even allow integration MIDI with RouterOS.

> **_Internals:_ Compiled Code**
> >
> In some cases, services can be compiled inside the /container, 
> with `/app/make.d/midi.mk` as an example that loads tools to build, then
> compiles [`midimonster`](https://midimonster.net) for the architecture, and finally
> removes build tools to preserve disk space.
> Internally, builder uses `apk ... -virtual ...`.  More complex builds will crash most RouterOS devices.
> e.g. `mk add-cute-tui` which uses Rust's `cargo`, and `mk pocketbase` which uses `go`
> – both will crash a RB1100AHx4.
> A set of "stress-*" targets are offered by `mk` if that's what you're looking to do.

## "Daemons" and Services

"Daemons" are called _service recipes_, are typically network services like `bind9` 
or applications like `lighttpd`.  Generally, services have no prefix like `tools-` or `add-`.
If you want to run "all services" (for testing), use `mk stress-services`, which starts most service recipes.
Service recipes are designed to be used on the `cmd=` in `/container` on RouterOS (or, provided by SERVICES= env var)
`make` will keep running generally by requesting they are foregrounded. 
For example, `cmd=`, `SERVICES`, or `mk` in `/container/shell` used
"midimonster mqtt http", all three services will be run by `make` using it's `-j #` option.

To see running services, you can use `/container/shell` with `ps -ef` to see running processes.
If needed, `killall <service_name>` can be used to stop a process. 
To look at what ports have services listening for network connections, use `netstat -plt`.


### Testing Services

Shell "job control" can be used to start services temporally from `/container/shell`.  
Essentially it's using ampersand & after the service name: `mk <service_recipe> &`.  
See `mk help-job-control` for details on shell job control,
but basically `jobs` shows anything backgrounded by you using the `&`, 
with `kill %1` stopping job 1, with number after `%` coming from `jobs`.


## Future

As more a proof-of-concept, not services in make.d may work out-of-the-box, but
most were tacitly tested to start.  Check the code in /app/make.d/*.mk for
any services you plan to use – most have some rough commentary on status and/or usage. 
 _Some things may_ never _run on low mem/CPU devices - but that's not something anyone can fix_.  
 And various parts are half-baked or placeholders, many
"recipes" only wrapping `apk add`, but do not move the package's config under `/app`.




