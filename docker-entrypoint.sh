#!/bin/bash
set -e

set_listen_addresses() {
	sedEscapedValue="$(echo "$1" | sed 's/[\/&]/\\&/g')"
	sed -ri "s/^#?(listen_addresses\s*=\s*)\S+/\1'$sedEscapedValue'/" "$PGDATA/postgresql.conf"
}

if [ "$1" = 'postgres' ]; then
	mkdir -p "$PGDATA"
	chown -R postgres "$PGDATA"

	chmod g+s /run/postgresql
	chown -R postgres /run/postgresql

	if [ -z "$(ls -A "$PGDATA")" ]; then
		gosu postgres initdb

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

		{ echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
	
		: ${POSTGRES_USER:=postgres}
		: ${POSTGRES_DB:=$POSTGRES_USER}

		if [ "$POSTGRES_DB" != 'postgres' ]; then
			gosu postgres pg_ctl start -w -D ${PGDATA} -o "-p 5433"
			gosu postgres createdb -p 5433 ${POSTGRES_DB} -E UTF8
			if [ "$POSTGRES_USER" = 'postgres' ]; then
				op='ALTER'
			else
				op='CREATE'
			fi
			sql="$op USER $POSTGRES_USER WITH SUPERUSER $pass;"
			echo sql is $sql
			gosu postgres psql -p 5433 -d dragon -c "create extension if not exists postgis;"
			gosu postgres psql -p 5433 -d dragon -c "create extension if not exists postgis_topology;"
			gosu postgres psql -p 5433 -d dragon -c "$sql"
			gosu postgres pg_ctl stop
		fi
		echo "Extension created"

		set_listen_addresses '*'

		echo
		echo 'PostgreSQL init process complete; ready for start up.'
		echo
	fi

	exec gosu postgres "$@"




fi
exec "$@"
