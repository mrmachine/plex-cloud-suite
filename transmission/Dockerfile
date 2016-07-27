FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        dockerize \
        jq \
        python \
        py-pip \
        transmission-daemon \
        tini \
    && rm -rf /var/cache/apk/*

ENV TRANSMISSION_PROCESS_TORRENTS_COMMIT=908b09434b85cb122eafa1901ea47b4567434d4e
RUN pip install https://github.com/mrmachine/transmission-process-torrents/archive/$TRANSMISSION_PROCESS_TORRENTS_COMMIT.zip

RUN rm /usr/bin/tini

EXPOSE 9091 51413 51413/udp
VOLUME /opt/transmission/var/
WORKDIR /opt/transmission/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/transmission/
RUN ln -fs /opt/transmission/bin/torrent-done.sh /etc/periodic/15min/
ENV PATH=/opt/transmission/bin:$PATH
