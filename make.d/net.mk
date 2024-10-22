

.PHONY: tools-network
tools-network: tools-dns add-nmap add-iperf3 add-trippy add-mtr

.PHONY: add-nmap
add-nmap: /usr/bin/nmap
.PRECIOUS: /usr/bin/nmap
/usr/bin/nmap:
	$(call apk_add, nmap nmap-doc)

.PHONY: add-iperf3
add-iperf3: /usr/bin/iperf3
.PRECIOUS: /usr/bin/iperf3
/usr/bin/iperf3:
	$(call apk_add, iperf3 iperf3-doc)

.PHONY: /usr/sbin/mtr
add-mtr: /usr/sbin/mtr
.PRECIOUS: /usr/sbin/mtr
/usr/sbin/mtr:
	$(call apk_add, mtr mtr-doc mtr-bash-completion )