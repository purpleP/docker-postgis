#!/bin/bash

: ${POSTGRES_DB:=$POSTGRES_USER}

su postgres -c '/usr/lib/postgresql/9.4/bin/initdb'
su postgres -c '/usr/lib/postgresql/9.4/bin/pg_ctl start -w -D ${PGDATA} -o "-p 5433"'
su postgres -c '/usr/lib/postgresql/9.4/bin/createuser -p 5433 dragon'
su postgres -c '/usr/lib/postgresql/9.4/bin/createdb -p 5433 dragon -E UTF8'
su postgres -c '/usr/lib/postgresql/9.4/bin/psql -p 5433 -d dragon -c "create extension if not exists postgis;"'
su postgres -c '/usr/lib/postgresql/9.4/bin/psql -p 5433 -d dragon -c "create extension if not exists postgis_topology;"'

su postgres -c '/usr/lib/postgresql/9.4/bin/pg_ctl -w  stop'
echo "$@"
su postgres -c 'exec "$@"'
