
.PHONY: tools-video
tools-video: add-ffmpeg add-sox add-gstreamer add-gstreamer

.PHONY: add-ffmpeg
add-ffmpeg: /usr/bin/ffmpeg /usr/bin/sox
.PRECIOUS: /usr/bin/ffmpeg
/usr/bin/ffmpeg:
	$(call apk_add, ffmpeg ffmpeg-doc libsrt libsrt-progs librist libsrt libsrtp)

.PHONY: add-sox
add-sox: /usr/bin/sox
.PRECIOUS: /usr/bin/sox
/usr/bin/sox:
	$(call apk_add, sox sox-doc)

.PHONY: add-gstreamer
add-gstreamer: /usr/bin/gst-launch-1.0
.PRECIOUS: /usr/bin/gst-launch-1.0
/usr/bin/gst-launch-1.0:
	$(call apk_add, gstreamer gstreamer-doc gstreamer-tools gst-plugins-good gst-plugins-base gst-plugins-base-doc)

.PHONY: add-tsduck
add-tsduck: /usr/local/bin/tsconfig add-python3

.PRECIOUS: /usr/local/bin/tsconfig
/usr/local/bin/tsconfig: /usr/local/src/tsduck/Makefile
# runtime deps, excluding smart-cart: pcsc-lite pcsc-lite-libs (not compiled)
	$(call apk_add, libedit libedit-doc librist libsrt libsrtp python3)
	$(call build_apk_addgroup, .build-tsduck, bash util-linux linux-headers alpine-sdk python3 coreutils diffutils procps  git make g++ cmake flex bison dos2unix curl tar zip dpkg python3 openssl-dev asciidoctor qpdf libedit-dev pcsc-lite-dev librist-dev libsrt-dev curl-dev)
	$(MAKE) -C /usr/local/src/tsduck -j 10 default NOTEST=1 NOPCSC=1 NODEKTEC=1 NOHIDES=1 NOVATEK=1 NOJAVA=1 NODOXYGEN=1
	mkdir -p /tmp/tsduck
	gem install asciidoctor-pdf rouge
	$(MAKE) -C /usr/local/src/tsduck -j 10 default NOTEST=1 NOPCSC=1 NODEKTEC=1 NOHIDES=1 NOVATEK=1 NOJAVA=1 NODOXYGEN=1 install-tools SYSROOT=/tmp/tsduck
	cp -r /tmp/tsduck/usr/* /usr/local
	$(call build_apk_cleanup, .build-tsduck)

.PRECIOUS: /usr/local/src/tsduck/Makefile
/usr/local/src/tsduck/Makefile:
	git clone https://github.com/tsduck/tsduck.git /usr/local/src/tsduck

# todo: the apk lines are a mess... it does not need all of them - just cut-and-paste
#	$(call apk_add_addgroup, .build-tsduck, bash python3 coreutils diffutils procps util-linux linux-headers git make cmake flex bison g++ dos2unix curl tar zip dpkg python3 openssl-dev asciidoctor qpdf libedit-dev pcsc-lite-dev librist-dev libsrt-dev curl-dev)
# libedit (20240517.3.1-r0)
# libedit-doc (20240517.3.1-r0)
# cjson (1.7.18-r0)
# mbedtls (3.6.2-r0)
# librist (0.2.10-r1)
# libsrt (1.5.3-r0)
# libsrtp (2.5.0-r1)

