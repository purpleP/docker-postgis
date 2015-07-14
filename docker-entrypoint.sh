#!/bin/bash

${POSTGRES_DB:=$POSTGRES_USER}

gosu postgres pg_ctl start -w -D ${PGDATA} -0 "-p 5433"
gosu postgres createuser ${POSTGRES_USER}
gosu postgres createdb ${POSTGRES_DB} -s -E UTF8
gosu postgres psql -d ${POSTGRES_DB} -c "create extension if not exists postgis;"
gosu postgres psql -d ${POSTGRES_DB} -c "create extension if not exists postgis_topology;"

pg_ctl -w  restart
