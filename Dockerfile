ARG TLSTYPE=openssl
FROM atdr.meo.ws/archiveteam/wget-lua:v1.21.3-at-${TLSTYPE} AS wget
FROM python:3.9-slim-buster
COPY --from=wget /wget /usr/local/bin/wget-lua
ENV LC_ALL=C
RUN echo deb http://deb.debian.org/debian buster-backports main contrib > /etc/apt/sources.list.d/backports.list \
 && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io update \
 && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io install gzip rsync liblua5.1-0 libluajit-5.1-2 libidn11 lua-socket lua-filesystem lua-sec lua-zip libpsl5 git poppler-utils luarocks libidn2-0-dev \
 && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io -t buster-backports install zstd libzstd-dev libzstd1 \
 && pip install --no-cache-dir requests seesaw zstandard \
 && luarocks install html-entities \
 && luarocks install idn2 \
 && chmod +x /usr/local/bin/wget-lua \
 && rm -rf /var/lib/apt/lists/*
RUN /usr/local/bin/wget-lua --help | grep -iE "gnu|warc|lua"
WORKDIR /grab
ONBUILD COPY . /grab
ONBUILD RUN test -x /grab/wget-at || ln -fs /usr/local/bin/wget-lua /grab/wget-at
STOPSIGNAL SIGINT
ENTRYPOINT ["run-pipeline3", "--disable-web-server", "pipeline.py"]
