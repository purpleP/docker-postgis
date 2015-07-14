FROM ubuntu:15.04

#ENV RELEASE_NAME lsb_release -sc
#RUN apt-get update && apt-get install wget
#RUN echo "deb http://apt.postgresql.org/pub/repos/apt ${RELEASE_NAME}-pgdg main" >> /etc/apt/sources.list
#RUN cat /etc/apt/sources.list
#RUN wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
           postgresql-9.4-postgis-2.1 \
	   curl \
	&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove curl

RUN mkdir /docker-entrypoint-initdb.d

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
RUN chmod +x /docker-entrypoint.sh
RUN ls -l /docker-entrypoint.sh

EXPOSE 5432
CMD ["postgres"]
