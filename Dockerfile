FROM ubuntu:15.04

#ENV RELEASE_NAME lsb_release -sc
#RUN apt-get update && apt-get install wget
#RUN echo "deb http://apt.postgresql.org/pub/repos/apt ${RELEASE_NAME}-pgdg main" >> /etc/apt/sources.list
#RUN cat /etc/apt/sources.list
#RUN wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

ENV PG_MAJOR 9.4

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
           postgresql-${PG_MAJOR}-postgis-2.1

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
RUN chmod +x /docker-entrypoint.sh
RUN ls -l /docker-entrypoint.sh
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
EXPOSE 5432
USER postgres

RUN mkdir /var/lib/postgresql/data
CMD ["postgres"]
