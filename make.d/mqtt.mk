## ** MQTT **
## > Uses mosquiitto as MQTT broker

DEFAULT_MQTT := mosquitto

.PHONY: mqtt
mqtt: $(DEFAULT_MQTT)

.PHONY: mosquitto
# "mosquitto" service target
MQTT_OPTS ?= -v -c /app/mosquitto/mosquitto.conf
mosquitto: /usr/sbin/mosquitto /app/mosquitto/mosquitto.conf
	$(info mosquitto starting)
	/usr/sbin/mosquitto $(MQTT_OPTS)

.PRECIOUS: /usr/sbin/mosquitto
/usr/sbin/mosquitto:
	$(call apk_add, mosquitto mosquitto-doc mosquitto-clients mqttui-bash-completion mqttui)

.PRECIOUS: /app/mosquitto/mosquitto.conf
/app/mosquitto/mosquitto.conf: /usr/sbin/mosquitto
	$(shell mkdir -p /app/mosquitto)
	$(file >/app/mosquitto/mosquitto.conf,$(mosquitto_conf_default))
	cp -n /etc/mosquitto/* /app/mosquitto
	chmod -R a+r /app/mosquitto
#	cp -n /etc/mosquitto/mosquitto.conf /etc/mosquitto/original.conf


define mosquitto_conf_default
# listener port-number [ip address/host name/unix socket path]
listener 1883 0.0.0.0

# Possible destinations are: stdout stderr syslog topic file dlt
log_dest stdout

# Boolean, default is false, to allow connection without providing a username.
# If set to false then a password file should be created to control access.
allow_anonymous true

endef