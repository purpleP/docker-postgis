#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
	chown -R postgres "$PGDATA"
	
	chmod g+s /run/postgresql
	chown -R postgres:postgres /run/postgresql

	if [ -z "$(ls -A "$PGDATA")" ]; then
		initdb
		sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
		if [ "$POSTGRES_PASSWORD" ]; then
			pass="PASSWORD '$POSTGRES_PASSWORD'"
			authMethod=md5
		else
			# The - option suppresses leading tabs but *not* spaces. :)
			cat >&2 <<-'EOWARN'
				****************************************************
				WARNING: No password has been set for the database.
					 This will allow anyone with access to the
					 Postgres port to access your database. In
					 Docker's default configuration, this is
					 effectively any other container on the same
					 system.
					 
					 Use "-e POSTGRES_PASSWORD=password" to set
					 it in "docker run".
				****************************************************
			EOWARN
		
			pass=
			authMethod=trust
		fi
	
		: ${POSTGRES_USER:=postgres}
		: ${POSTGRES_DB:=$POSTGRES_USER}

		if [ "$POSTGRES_DB" != 'postgres' ]; then
			pg_ctl start -w -D ${PGDATA} -o "-p 5433"
			createuser -p 5433 ${POSTGRES_USER}
			createdb -p 5433 ${POSTGRES_USER} -E UTF8
			sql = 'alter user "$POSTGRES_USER" with SUPERUSER PASSWORD "$pass";'
			psql -p 5433 -d dragon -c "create extension if not exists postgis;"
			psql -p 5433 -d dragon -c "create extension if not exists postgis_topology;"
			psql -p 5433 -d dragon -c ${sql}
			pg_ctl stop
			{ echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
		fi
	fi




fi
exec "$@"
