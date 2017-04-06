FROM buildpack-deps:xenial

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
    && apt-add-repository multiverse \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apache2-utils \
        bc \
        encfs \
        ffmpeg \
        jq \
        less \
        nano \
        nginx \
        p7zip \
        python-babel \
        python-cryptography \
        python-dev \
        python-lxml \
        python-openssl \
        python-pip \
        python-setuptools \
        rsync \
        supervisor \
        transmission-cli \
        transmission-daemon \
        unionfs-fuse \
        unrar \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` \
    && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get install --no-install-recommends \
        gcsfuse \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/bin \
    && wget -nv https://dl.eff.org/certbot-auto \
    && chmod a+x certbot-auto \
    && certbot-auto --non-interactive --version \
    && ln -s /root/.local/share/letsencrypt/bin/certbot /usr/local/bin/certbot \
    && rm -rf /var/lib/apt/lists/*

ENV PMS_VERSION=1.5.3.3580-4b377d295
RUN URL="https://downloads.plex.tv/plex-media-server/${PMS_VERSION}/plexmediaserver_${PMS_VERSION}_amd64.deb"; FILE="$(mktemp)"; wget -nv -O "$FILE" "$URL" \
    && dpkg -i "$FILE"; rm "$FILE"

ENV DOCKERIZE_VERSION=0.4.0
RUN wget -nv -O - "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" | tar -xz -C /usr/local/bin/ -f -

ENV TINI_VERSION=0.14.0
RUN wget -nv -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static"
RUN chmod +x /usr/local/bin/tini

RUN pip install --no-cache-dir hardlink==0.2

ENV PATH=/opt/bin:$PATH

EXPOSE 80
EXPOSE 443
EXPOSE 32400
EXPOSE 51413 51413/udp

VOLUME /etc/letsencrypt
VOLUME /mnt/local-storage
VOLUME /opt/var

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["supervisor.sh"]

WORKDIR /opt/

COPY bin/ /opt/bin/
COPY etc/ /opt/etc/
