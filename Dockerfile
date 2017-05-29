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
        ffmpeg \
        fuse \
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
        supervisor \
        transmission-cli \
        transmission-daemon \
        unionfs-fuse \
        unrar \
        unzip \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/bin \
    && wget -nv https://dl.eff.org/certbot-auto \
    && chmod a+x certbot-auto \
    && certbot-auto --non-interactive --version \
    && ln -s /root/.local/share/letsencrypt/bin/certbot /usr/local/bin/certbot \
    && rm -rf /var/lib/apt/lists/*

ENV DOCKERIZE_VERSION="0.4.0"
RUN wget -nv -O - "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" | tar -xz -C /usr/local/bin/ -f -

ENV LOGENTRIES_VERSION="1.4.41"
RUN echo 'deb http://rep.logentries.com/ xenial main' > /etc/apt/sources.list.d/logentries.list
RUN apt-get update \
    && apt-get install -y --allow-unauthenticated --no-install-recommends \
        logentries="${LOGENTRIES_VERSION}" \
    && rm -rf /var/lib/apt/lists/*

ENV RCLONE_VERSION="v1.36"
RUN wget -nv "https://downloads.rclone.org/rclone-${RCLONE_VERSION}-linux-amd64.zip" \
    && unzip -j -d /usr/local/bin "rclone-${RCLONE_VERSION}-linux-amd64.zip" */rclone \
    && rm "rclone-${RCLONE_VERSION}-linux-amd64.zip"
ENV PATH="/opt/rclone:$PATH"

ENV TINI_VERSION="0.14.0"
RUN wget -nv -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static"
RUN chmod +x /usr/local/bin/tini

RUN pip install --no-cache-dir hardlink==0.2

ENV PATH=/opt/bin:$PATH

EXPOSE 80
EXPOSE 443
EXPOSE 51413 51413/udp

VOLUME /etc/letsencrypt
VOLUME /mnt/local
VOLUME /opt/var

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["supervisor.sh"]

WORKDIR /opt/

COPY bin/ /opt/bin/
COPY etc/ /opt/etc/
