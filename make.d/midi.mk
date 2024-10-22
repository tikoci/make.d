## ** MIDI **
# > just `midimonster` but it more than MIDI

.PHONY: midimonster
MIDI_CONFIG ?= rtpmidi-mqtt.cfg
MIDI_OPTS ?=
# note: to avoid error with python backend, add "mk python3" to install python3
#       not installed since python3 add 50M+
# todo: adding logging is tricker, since logger needs
# todo: but this works to send to local syslogd - but easier cause it to background
# MIDI_LOG_OPTS ?= 2>&1 | logger -t midimonster
midimonster: add-midimonster 
	$(info midimonster starting)
# hack: src directory must exist before being dep in make...
#	$(shell mkdir -p /usr/local/src/midimonster)
	/usr/local/bin/midimonster /app/midimonster/maps/$(MIDI_CONFIG) $(MIDI_OPTS)
# note: native audio things are not going to work
#       so hardware is skip for runtime, this gives errors when starting
#       so "mk midimonster-extras" will add hardware MIDI/audio support on "real" VM.

.PHONY: add-midimonster
add-midimonster: /usr/local/bin/midimonster

.PHONY: midimonster-drivers
# MIDI_EXTRA_APKS ?= alsa-lib-dev jack-dev libevdev-dev lua5.3 lua5.3-libs
midimonster-drivers: midimonster
	$(call apk_add, python3 alsa-lib-dev jack-dev libevdev-dev)


# todo: alpine should link the version specifc ones, dunno
#       but allows 'lua' with 'lua5.3' at CLI
#/usr/local/bin/lua:
#	$(call apk_add, lua5.3 lua5.3-doc lua5.3-libs)
#	$(shell ln -s /usr/bin/lua5.3 /usr/local/bin/lua)

# This is more interesting... we build midimonster inside the container, if needed
# note: this is NOT a .PHONY - we actually want to check if FILE EXIST - here 'midimonster'
#       if not... get tools, build it, and remove build-only tools
.PRECIOUS:  /usr/local/bin/midimonster
/usr/local/bin/midimonster: /usr/local/src/midimonster/Makefile /usr/local/src/midimonster/patches
# these APKs use at runtime for midimonster
	$(call apk_add, $(MIDI_EXTRA_APKS) openssl lua5.3 lua5.3-libs)
# Linux dev tools/libraries used to build only (and removed)
	$(call build_apk_addgroup, .build-midimonster, \
		git \
		build-base \
		linux-headers \
		alpine-sdk \
		lua5.3-dev \
		jack-dev \
		alsa-lib-dev \
		openssl-dev \
		libevdev-dev \
		python3-dev)
# create directories
	$(shell mkdir -p /app/midimonster/maps)
	$(shell mkdir -p /app/midimonster/docs)
	$(file >/app/midimonster/maps/rtpmidi-mqtt.cfg,$(midimonster_rtpmidi_mqtt_cfg))
# actually build `midimonster`
# ... and set file paths that get compiled into `midimonster`
#     needed to find .so libs on "real" container.
	$(MAKE) -C /usr/local/src/midimonster clean MAKEFLAGS= PREFIX="/usr/local" DEFAULT_CFG="/etc/monster.cfg" PLUGINS="/usr/local/lib/midimonster" 
	$(MAKE) -C /usr/local/src/midimonster MAKEFLAGS= PREFIX="/usr/local" DEFAULT_CFG="/etc/monster.cfg" PLUGINS="/usr/local/lib/midimonster" 
	$(MAKE) -C /usr/local/src/midimonster install MAKEFLAGS= PREFIX="/usr/local" DEFAULT_CFG="/etc/monster.cfg" PLUGINS="/usr/local/lib/midimonster"
# create a default configuration file, in default location
	cp -n /usr/local/src/midimonster/monster.cfg /etc/monster.cfg
# copy files from "real" locations to /app for easy-of-mounting
	cp -n /usr/local/share/midimonster/* /app/midimonster/maps
	cp /usr/local/src/midimonster/backends/*.md /app/midimonster/docs
	cp /usr/local/src/midimonster/*.md /app/midimonster
	cp /usr/local/src/midimonster/*.txt /app/midimonster
# safely remove the build tools we installed
	$(call build_apk_cleanup, .build-midimonster)
	$(info done building midimonster)

.PRECIOUS: /usr/local/src/midimonster/Makefile
/usr/local/src/midimonster/Makefile:
# use `git` to fetch `midimonster` source code from GitHub
#	$(shell mkdir -p /usr/local/src/midimonster)
	git clone https://github.com/cbdevnet/midimonster.git /usr/local/src/midimonster

.PRECIOUS: /usr/local/src/midimonster/patches
/usr/local/src/midimonster/patches: /usr/local/src/midimonster/Makefile
# in order to work on Alpine, `midimonster` need minor changes
# to the source code, there are stored `diff` file and
# need to be apply'ed to GitHub downloaded source to work with Alpine
# note: the patch file is define'd below
	$(file >/usr/local/src/midimonster/patches,$(midimonster_alpine_patches))
	cd /usr/local/src/midimonster && git apply /usr/local/src/midimonster/patches

# file above is defined here...
define midimonster_rtpmidi_mqtt_cfg
; RTP MIDI + MQTT example configuration, directly using MQTT backend

[backend rtpmidi]
; This causes the backend itself to print channel values as they come in
detect = on
; When connecting multiple MIDIMonster hosts via RTP MIDI
; ... set this to something different on each computer
mdns-name = midimonster-host

[rtpmidi rtp]
mode = apple
; Invite everyone we see on the network
invite = *
; Or, alternativeliy, depending on rtpmidi topology
; join = *


[mqtt mqtt1]
; no backend is required for MQTT
; change host if broker, such as mosquitto, is not on local system
host = mqtt://localhost
/midi/in/{0..15}/note/{0..127} = range 0 127
/midi/in/{0..15}/cc/{0..127} = range 0 127

[map]
; example mapping where in and out are seperate topic trees
rtp.ch{0..15}.cc{0..127} > mqtt1./midi/out/{0..15}/cc/{0..127}
rtp.ch{0..15}.note{0..127} > mqtt1./midi/out/{0..15}/note/{0..127}
mqtt1./midi/in/{0..15}/note/{0..127} > rtp.ch{0..15}.note{0..127}
mqtt1./midi/in/{0..15}/cc/{0..127} > rtp.ch{0..15}.cc{0..127}
endef


define midimonster_alpine_patches
:diff --git a/backends/Makefile b/backends/Makefile
index 72ba776..2dd6917 100644
--- a/backends/Makefile
+++ b/backends/Makefile
@@ -33,7 +33,10 @@ endif
 ifeq ($$(SYSTEM),Darwin)
 LDFLAGS += -undefined dynamic_lookup
 endif
-
+# Add build flag for Alpine Linux (uses musl not glibc)
+ifeq ($$(shell grep -o 'ID=alpine' /etc/os-release 2>/dev/null), ID=alpine)
+    CFLAGS += -DLINUX_ALPINE
+endif
 # Most of these next few backends just pull in the backend lib, some set additional flags
 artnet.so: ADDITIONAL_OBJS += $$(BACKEND_LIB)
 artnet.dll: ADDITIONAL_OBJS += $$(BACKEND_LIB)
diff --git a/backends/jack.c b/backends/jack.c
index fe74a80..5ad8e90 100644
--- a/backends/jack.c
+++ b/backends/jack.c
@@ -12,7 +12,7 @@

 #define JACKEY_SIGNAL_TYPE "http://jackaudio.org/metadata/signal-type"

-#ifdef __APPLE__
+#if defined(__APPLE__) || defined(LINUX_ALPINE)
 	#ifndef PTHREAD_MUTEX_ADAPTIVE_NP
 		#define PTHREAD_MUTEX_ADAPTIVE_NP PTHREAD_MUTEX_DEFAULT
 	#endif
diff --git a/backends/visca.c b/backends/visca.c
index 6ae14d9..b76d73e 100644
--- a/backends/visca.c
+++ b/backends/visca.c
@@ -7,6 +7,9 @@
 #ifdef __linux__
 	#include <sys/ioctl.h>
 	#include <asm/termbits.h>
+#ifdef LINUX_ALPINE
+	#include <asm/ioctls.h>
+#endif
 #elif __APPLE__
 	#include <sys/ioctl.h>
 	#include <IOKit/serial/ioss.h>
endef
