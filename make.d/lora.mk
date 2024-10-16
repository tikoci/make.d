## ** LORAWAN **
# > PLACEHOLDER - still looking for SIMPLE LoRa Network Server to use...

.PHONY: lorawan-server
lorawan-server: # erla
	$(info ** lorawan-server **)
	$(error unimplemented)
	$(info - tested in _seperate_ erlang-based container, but using APK erlang here does not)
	$(info - possible to borrow Erlang Dockerfile to build erlang to run lorawan-server... )
	$(info   ...but perhaps there is something even simplier) 

# ** chripstack ** - unfinished and disabled
# note: chirpstack is very complex to build, and has postgres-dep which is not ideal
#       possible, but way more complex than needed for simplier LoRa use case...

#.PHONY: chirpstack
#chirpstack: # postgres redis
#	$(shell mkdir -p /app/chirpstack/sql)
#	$(file >/app/chirpstack/sql/init.sql,$(chirp_sql_init))
#	su postgres -c "psql -f /app/chirpstack/sql/init.sql"
#	$(error unimplemented)

#define chirp_sql_init 
#-- create role for authentication
#create role chirpstack with login password 'chirpstack';
#
#-- create database
#create database chirpstack with owner chirpstack;
#
#-- change to chirpstack database
#\c chirpstack
#
#-- create pg_trgm extension
#create extension pg_trgm;
#
#-- exit psql
#\q
#endef
