# ** DNS ** is "pointer recipe" to the default DNS server since
# todo: check ports / conflicts...  only one can be used

# "alias" name for a dns resolver
DEFAULT_DNS ?= blocky

.PHONY: dns
dns: $(DEFAULT_DNS)

/usr/bin/dig:
	$(call apk_add, bind-tools)

.PHONY: dns-tools
dns-tools: /usr/bin/dig

.PHONY: dig
dig: /usr/bin/dig
	dig

.PHONY: blocky
BLOCKY_CONFIG := example.yml
blocky: /usr/bin/blocky
	/usr/bin/blocky --config /app/blocky/$(BLOCKY_CONFIG)

.PRECIOUS: /usr/bin/blocky
/usr/bin/blocky:
	mkdir -p /app/blocky
	$(call apk_add, blocky bind-tools)
	cp -n /etc/blocky/config.example.yml /app/blocky/example.yml
	echo "$$blocky_config_ref" > /app/blocky/full-reference.yml
	echo "$$blocky_readme" > /app/blocky/README.md

.PHONY: bind9
BIND9_PORT ?= 53
BIND9_OPTS ?= -c /app/bind9/named.conf -p $(BIND9_PORT)
BIND9_RUN_FG ?= -f
bind9: /usr/sbin/named
	/usr/sbin/named $(BIND9_RUN_FG) $(BIND9_OPTS)

.PRECIOUS: /usr/sbin/named
/usr/sbin/named:
	mkdir -p /app/bind9
	$(call apk_add, bind bind-doc bind-tools)
	cp -n /etc/bind/* /app/bind9
	cp -n /app/bind9/named.conf.recursive /app/bind9/named.conf


define blocky_readme
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/0xERR0R/blocky/makefile.yml "Make")](https://github.com/0xERR0R/blocky/actions/workflows/makefile.yml)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/0xERR0R/blocky/release.yml "Release")](https://github.com/0xERR0R/blocky/actions/workflows/release.yml)
[![GitHub latest version](https://img.shields.io/github/v/release/0xERR0R/blocky "Latest version")](https://github.com/0xERR0R/blocky/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/0xERR0R/blocky "Latest release date")](https://github.com/0xERR0R/blocky/releases)
[![GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/0xERR0R/blocky "Go version")](#)
[![Docker pulls](https://img.shields.io/docker/pulls/spx01/blocky "Latest version")](https://hub.docker.com/r/spx01/blocky)
[![Docker Image Size (latest)](https://img.shields.io/docker/image-size/spx01/blocky/latest)](https://hub.docker.com/r/spx01/blocky)
[![Codecov](https://img.shields.io/codecov/c/gh/0xERR0R/blocky "Code coverage")](https://codecov.io/gh/0xERR0R/blocky)
[![Codacy grade](https://img.shields.io/codacy/grade/8fcd8f8420b8419c808c47af58ed9282 "Codacy grade")](#)
[![Go Report Card](https://goreportcard.com/badge/github.com/0xERR0R/blocky)](https://goreportcard.com/report/github.com/0xERR0R/blocky)
[![Donation](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-blueviolet.svg)](https://ko-fi.com/0xerr0r)

<p align="center">
	<img height="200" src="https://github.com/0xERR0R/blocky/blob/main/docs/blocky.svg">
</p>

# Blocky

Blocky is a DNS proxy and ad-blocker for the local network written in Go with following features:

## Features

- **Blocking** - Blocking of DNS queries with external lists (Ad-block, malware) and allowlisting

	- Definition of allow/denylists per client group (Kids, Smart home devices, etc.)
	- Periodical reload of external allow/denylists
	- Regex support
	- Blocking of request domain, response CNAME (deep CNAME inspection) and response IP addresses (against IP lists)

- **Advanced DNS configuration** - not just an ad-blocker

	- Custom DNS resolution for certain domain names
	- Conditional forwarding to external DNS server
	- Upstream resolvers can be defined per client group

- **Performance** - Improves speed and performance in your network

	- Customizable caching of DNS answers for queries -> improves DNS resolution speed and reduces amount of external DNS
		queries
	- Prefetching and caching of often used queries
	- Using multiple external resolver simultaneously
	- Low memory footprint

- **Various Protocols** - Supports modern DNS protocols

	- DNS over UDP and TCP
	- DNS over HTTPS (aka DoH)
	- DNS over TLS (aka DoT)

- **Security and Privacy** - Secure communication

	- Supports modern DNS extensions: DNSSEC, eDNS, ...
	- Free configurable blocking lists - no hidden filtering etc.
	- Provides DoH Endpoint
	- Uses random upstream resolvers from the configuration - increases your privacy through the distribution of your DNS
		traffic over multiple provider
	- Blocky does **NOT** collect any user data, telemetry, statistics etc.

- **Integration** - various integration

	- [Prometheus](https://prometheus.io/) metrics
	- Prepared [Grafana](https://grafana.com/) dashboards (Prometheus and database)
	- Logging of DNS queries per day / per client in CSV format or MySQL/MariaDB/PostgreSQL/Timescale database - easy to
		analyze
	- Various REST API endpoints
	- CLI tool

- **Simple configuration** - single or multiple configuration files in YAML format

	- Simple to maintain
	- Simple to backup

- **Simple installation/configuration** - blocky was designed for simple installation

	- Stateless (no database, no temporary files)
	- Docker image with Multi-arch support
	- Single binary
	- Supports x86-64 and ARM architectures -> runs fine on Raspberry PI
	- Community supported Helm chart for k8s deployment

## Quick start

You can jump to [Installation](https://0xerr0r.github.io/blocky/latest/installation/) chapter in the documentation.

## Full documentation

You can find full documentation and configuration examples
at: [https://0xERR0R.github.io/blocky/](https://0xERR0R.github.io/blocky/)

## Contribution

Issues, feature suggestions and pull requests are welcome!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G25XZQG)
endef


define blocky_config_ref
upstream:
	# these external DNS resolvers will be used. Blocky picks 2 random resolvers from the list for each query
	# format for resolver: [net:]host:[port][/path]. net could be empty (default, shortcut for tcp+udp), tcp+udp, tcp, udp, tcp-tls or https (DoH). If port is empty, default port will be used (53 for udp and tcp, 853 for tcp-tls, 443 for https (Doh))
	# this configuration is mandatory, please define at least one external DNS resolver
	default:
		# example for tcp+udp IPv4 server (https://digitalcourage.de/)
		- 5.9.164.112
		# Cloudflare
		- 1.1.1.1
		# example for DNS-over-TLS server (DoT)
		- tcp-tls:fdns1.dismail.de:853
		# example for DNS-over-HTTPS (DoH)
		- https://dns.digitale-gesellschaft.ch/dns-query
	# optional: use client name (with wildcard support: * - sequence of any characters, [0-9] - range)
	# or single ip address / client subnet as CIDR notation
	laptop*:
		- 123.123.123.123

# optional: timeout to query the upstream resolver. Default: 2s
upstreamTimeout: 2s

# optional: If true, blocky will fail to start unless at least one upstream server per group is reachable. Default: false
startVerifyUpstream: true

# optional: Determines how blocky will create outgoing connections. This impacts both upstreams, and lists.
# accepted: dual, v4, v6
# default: dual
connectIPVersion: dual

# optional: custom IP address(es) for domain name (with all sub-domains). Multiple addresses must be separated by a comma
# example: query "printer.lan" or "my.printer.lan" will return 192.168.178.3
customDNS:
	customTTL: 1h
	# optional: if true (default), return empty result for unmapped query types (for example TXT, MX or AAAA if only IPv4 address is defined).
	# if false, queries with unmapped types will be forwarded to the upstream resolver
	filterUnmappedTypes: true
	# optional: replace domain in the query with other domain before resolver lookup in the mapping
	rewrite:
		example.com: printer.lan
	mapping:
		printer.lan: 192.168.178.3,2001:0db8:85a3:08d3:1319:8a2e:0370:7344

# optional: definition, which DNS resolver(s) should be used for queries to the domain (with all sub-domains). Multiple resolvers must be separated by a comma
# Example: Query client.fritz.box will ask DNS server 192.168.178.1. This is necessary for local network, to resolve clients by host name
conditional:
	# optional: if false (default), return empty result if after rewrite, the mapped resolver returned an empty answer. If true, the original query will be sent to the upstream resolver
	# Example: The query "blog.example.com" will be rewritten to "blog.fritz.box" and also redirected to the resolver at 192.168.178.1. If not found and if `fallbackUpstream` was set to `true`, the original query "blog.example.com" will be sent upstream.
	# Usage: One usecase when having split DNS for internal and external (internet facing) users, but not all subdomains are listed in the internal domain.
	fallbackUpstream: false
	# optional: replace domain in the query with other domain before resolver lookup in the mapping
	rewrite:
		example.com: fritz.box
	mapping:
		fritz.box: 192.168.178.1
		lan.net: 192.168.178.1,192.168.178.2

# optional: use black and white lists to block queries (for example ads, trackers, adult pages etc.)
blocking:
	# definition of blacklist groups. Can be external link (http/https) or local file
	blackLists:
		ads:
			- https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
			- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
			- http://sysctl.org/cameleon/hosts
			- https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
			- |
				# inline definition with YAML literal block scalar style
				# hosts format
				someadsdomain.com
		special:
			- https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts
	# definition of whitelist groups. Attention: if the same group has black and whitelists, whitelists will be used to disable particular blacklist entries. If a group has only whitelist entries -> this means only domains from this list are allowed, all other domains will be blocked
	whiteLists:
		ads:
			- whitelist.txt
			- |
				# inline definition with YAML literal block scalar style
				# hosts format
				whitelistdomain.com
				# this is a regex
				/^banners?[_.-]/
	# definition: which groups should be applied for which client
	clientGroupsBlock:
		# default will be used, if no special definition for a client name exists
		default:
			- ads
			- special
		# use client name (with wildcard support: * - sequence of any characters, [0-9] - range)
		# or single ip address / client subnet as CIDR notation
		laptop*:
			- ads
		192.168.178.1/24:
			- special
	# which response will be sent, if query is blocked:
	# zeroIp: 0.0.0.0 will be returned (default)
	# nxDomain: return NXDOMAIN as return code
	# comma separated list of destination IP addresses (for example: 192.100.100.15, 2001:0db8:85a3:08d3:1319:8a2e:0370:7344). Should contain ipv4 and ipv6 to cover all query types. Useful with running web server on this address to display the "blocked" page.
	blockType: zeroIp
	# optional: TTL for answers to blocked domains
	# default: 6h
	blockTTL: 1m
	# optional: automatically list refresh period (in duration format). Default: 4h.
	# Negative value -> deactivate automatically refresh.
	# 0 value -> use default
	refreshPeriod: 4h
	# optional: timeout for list download (each url). Default: 60s. Use large values for big lists or slow internet connections
	downloadTimeout: 4m
	# optional: Download attempt timeout. Default: 60s
	downloadAttempts: 5
	# optional: Time between the download attempts. Default: 1s
	downloadCooldown: 10s
	# optional: if failOnError, application startup will fail if at least one list can't be downloaded / opened. Default: blocking
	startStrategy: failOnError

# optional: configuration for caching of DNS responses
caching:
	# duration how long a response must be cached (min value).
	# If <=0, use response's TTL, if >0 use this value, if TTL is smaller
	# Default: 0
	minTime: 5m
	# duration how long a response must be cached (max value).
	# If <0, do not cache responses
	# If 0, use TTL
	# If > 0, use this value, if TTL is greater
	# Default: 0
	maxTime: 30m
	# Max number of cache entries (responses) to be kept in cache (soft limit). Useful on systems with limited amount of RAM.
	# Default (0): unlimited
	maxItemsCount: 0
	# if true, will preload DNS results for often used queries (default: names queried more than 5 times in a 2-hour time window)
	# this improves the response time for often used queries, but significantly increases external traffic
	# default: false
	prefetching: true
	# prefetch track time window (in duration format)
	# default: 120
	prefetchExpires: 2h
	# name queries threshold for prefetch
	# default: 5
	prefetchThreshold: 5
	# Max number of domains to be kept in cache for prefetching (soft limit). Useful on systems with limited amount of RAM.
	# Default (0): unlimited
	prefetchMaxItemsCount: 0
	# Time how long negative results (NXDOMAIN response or empty result) are cached. A value of -1 will disable caching for negative results.
	# Default: 30m
	cacheTimeNegative: 30m

# optional: configuration of client name resolution
clientLookup:
	# optional: this DNS resolver will be used to perform reverse DNS lookup (typically local router)
	upstream: 192.168.178.1
	# optional: some routers return multiple names for client (host name and user defined name). Define which single name should be used.
	# Example: take second name if present, if not take first name
	singleNameOrder:
		- 2
		- 1
	# optional: custom mapping of client name to IP addresses. Useful if reverse DNS does not work properly or just to have custom client names.
	clients:
		laptop:
			- 192.168.178.29
# optional: configuration for prometheus metrics endpoint
prometheus:
	# enabled if true
	enable: true
	# url path, optional (default '/metrics')
	path: /metrics

# optional: write query information (question, answer, client, duration etc.) to daily csv file
queryLog:
	# optional one of: mysql, postgresql, csv, csv-client. If empty, log to console
	type: mysql
	# directory (should be mounted as volume in docker) for csv, db connection string for mysql/postgresql
	target: db_user:db_password@tcp(db_host_or_ip:3306)/db_name?charset=utf8mb4&parseTime=True&loc=Local
	#postgresql target: postgres://user:password@db_host_or_ip:5432/db_name
	# if > 0, deletes log files which are older than ... days
	logRetentionDays: 7
	# optional: Max attempts to create specific query log writer, default: 3
	creationAttempts: 1
	# optional: Time between the creation attempts, default: 2s
	creationCooldown: 2s
	# optional: Which fields should be logged. You can choose one or more from: clientIP, clientName, responseReason, responseAnswer, question, duration. If not defined, it logs all fields
	fields:
		- clientIP
		- duration

# optional: Blocky can synchronize its cache and blocking state between multiple instances through redis.
redis:
	# Server address and port or master name if sentinel is used
	address: redismaster
	# Username if necessary
	username: usrname
	# Password if necessary
	password: passwd
	# Database, default: 0
	database: 2
	# Connection is required for blocky to start. Default: false
	required: true
	# Max connection attempts, default: 3
	connectionAttempts: 10
	# Time between the connection attempts, default: 1s
	connectionCooldown: 3s
	# Sentinal username if necessary
	sentinelUsername: usrname
	# Sentinal password if necessary
	sentinelPassword: passwd
	# List with address and port of sentinel hosts(sentinel is activated if at least one sentinel address is configured)
	sentinelAddresses:
		- redis-sentinel1:26379
		- redis-sentinel2:26379
		- redis-sentinel3:26379

# optional: Mininal TLS version that the DoH and DoT server will use
minTlsServeVersion: 1.3
# if https port > 0: path to cert and key file for SSL encryption. if not set, self-signed certificate will be generated
#certFile: server.crt
#keyFile: server.key
# optional: use these DNS servers to resolve blacklist urls and upstream DNS servers. It is useful if no system DNS resolver is configured, and/or to encrypt the bootstrap queries.
bootstrapDns:
	- tcp+udp:1.1.1.1
	- https://1.1.1.1/dns-query
	- upstream: https://dns.digitale-gesellschaft.ch/dns-query
		ips:
			- 185.95.218.42

# optional: drop all queries with following query types. Default: empty
filtering:
	queryTypes:
		- AAAA

# optional: if path defined, use this file for query resolution (A, AAAA and rDNS). Default: empty
hostsFile:
	# optional: Path to hosts file (e.g. /etc/hosts on Linux)
	filePath: /etc/hosts
	# optional: TTL, default: 1h
	hostsTTL: 60m
	# optional: Time between hosts file refresh, default: 1h
	refreshPeriod: 30m
	# optional: Whether loopback hosts addresses (127.0.0.0/8 and ::1) should be filtered or not, default: false
	filterLoopback: true

# optional: ports configuration
ports:
	# optional: DNS listener port(s) and bind ip address(es), default 53 (UDP and TCP). Example: 53, :53, "127.0.0.1:5353,[::1]:5353"
	dns: 53
	# optional: Port(s) and bind ip address(es) for DoT (DNS-over-TLS) listener. Example: 853, 127.0.0.1:853
	tls: 853
	# optional: Port(s) and optional bind ip address(es) to serve HTTPS used for prometheus metrics, pprof, REST API, DoH... If you wish to specify a specific IP, you can do so such as 192.168.0.1:443. Example: 443, :443, 127.0.0.1:443,[::1]:443
	https: 443
	# optional: Port(s) and optional bind ip address(es) to serve HTTP used for prometheus metrics, pprof, REST API, DoH... If you wish to specify a specific IP, you can do so such as 192.168.0.1:4000. Example: 4000, :4000, 127.0.0.1:4000,[::1]:4000
	http: 4000

# optional: logging configuration
log:
	# optional: Log level (one from debug, info, warn, error). Default: info
	level: info
	# optional: Log format (text or json). Default: text
	format: text
	# optional: log timestamps. Default: true
	timestamp: true
	# optional: obfuscate log output (replace all alphanumeric characters with *) for user sensitive data like request domains or responses to increase privacy. Default: false
	privacy: false

# optional: add EDE error codes to dns response
ede:
	# enabled if true, Default: false
	enable: true
endef