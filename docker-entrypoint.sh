#!/bin/bash

: ${POSTGRES_DB:=$POSTGRES_USER}
pass=
authMethod=trust
initdb

sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
pg_ctl start -w -D ${PGDATA} -o "-p 5433"
createuser -p 5433 dragon
createdb -p 5433 dragon -E UTF8
psql -p 5433 -d dragon -c "create extension if not exists postgis;"
psql -p 5433 -d dragon -c "create extension if not exists postgis_topology;"

echo
		
		{ echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
pg_ctl -w  stop
echo "$@"
exec "$@"
