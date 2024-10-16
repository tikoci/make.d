
# todo: if postgres is only target it container will stop since Makefile will finish
#       ... while goal is all services wait in foreground in make.d - postgres violates it.
# note: it's expected for larger database needs, a seperate instance should be used & postgres is picky

.PHONY: all-databases 
all-databases: redis sqlite

# note: all-databases refers to file-based, no service datas - all-* should packages, not services

.PHONY: postgres
# from: https://luppeng.wordpress.com/2020/02/28/install-and-start-postgresql-on-alpine-linux/
postgres: /app/postgres/data/postgresql.conf /usr/bin/pg_ctl /run/postgresql
#	su postgres -c "echo 'unix_socket_directories = /tmp' >> /app/postgres/data/postgresql.conf"
	su postgres -c 'mkdir -p /run/postgresql'
	su postgres -c 'pg_ctl start -D /app/postgres/data'

.PHONY: pqsl
pqsl:
	su postgres -c 'psql'

.PRECIOUS: /usr/bin/pg_ctl
/usr/bin/pg_ctl:
	$(call apk_add, postgresql postgresql-doc shadow shadow-doc)

/run/postgresql: /usr/bin/pg_ctl
	mkdir -p /run/postgresql
	chgrp -R postgres /run/postgresql
	chown -R postgres /run/postgresql

# needed? .ONESHELL: /app/postgres/data/postgresql.conf
.PRECIOUS: /app/postgres/data/postgresql.conf 
/app/postgres/data/postgresql.conf: /usr/bin/pg_ctl /run/postgresql
	mkdir -p /app/postgres/data 
	chgrp -R postgres /app/postgres
	chown -R postgres /app/postgres
	usermod postgres -d /app/postgres
	su postgres -c "initdb -D /app/postgres/data"
	su postgres -c "echo 'host all all 0.0.0.0/0 md5' >> /app/postgres/data/pg_hba.conf"
	su postgres -c "echo listen_addresses=\'*\' >> /app/postgres/data/postgresql.conf"
#	su postgres -c "echo unix_socket_directories=\'/app/postgres/run\' >> /app/postgres/data/postgresql.conf"

.PHONY: sqlite
sqlite: /usr/bin/sqlite3 
.PRECIOUS: /usr/bin/sqlite3
/usr/bin/sqlite3:
	$(call apk_add, sqlite sqlite-doc sqlite-tools)

.PHONY: redis
redis:
	$(call apk_add, redis)