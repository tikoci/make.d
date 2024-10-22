
.PHONY: tools-all-vpns
# note: we don't want services, so /usr/[s]bin are used here, to get the APKs
tools-all-vpns: tools-wireguard add-cloudflared add-openvpn add-pptpclient

.PHONY: add-cloudflared
add-cloudflared: /usr/bin/cloudflared
.PRECIOUS: /usr/bin/cloudflared
/usr/bin/cloudflared:
	$(call apk_add_testing, cloudflared cloudflared-doc)

.PHONY: add-openvpn
add-openvpn: /usr/sbin/openvpn
.PRECIOUS: /usr/sbin/openvpn
/usr/sbin/openvpn:
	$(call apk_add, openvpn openvpn-doc)

.PHONY: tools-wireguard
tools-wireguard: /usr/bin/wg
.PRECIOUS: /usr/bin/wg
/usr/bin/wg:
	$(call apk_add, wireguard-tools wireguard-tools-bash-completion wireguard-tools-doc)

.PHONY: add-pptpclient
add-pptpclient: /usr/sbin/pppd /usr/sbin/pptpsetup
.PRECIOUS: /usr/sbin/pppd
/usr/sbin/pppd:
	$(call apk_add_testing, pptpclient, pptpclient-doc)
.PRECIOUS: /usr/sbin/pptpsetup
/usr/sbin/pptpsetup: /usr/sbin/pppd
