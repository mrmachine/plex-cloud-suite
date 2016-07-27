FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        jq \
        transmission-daemon \
        tini \
    && rm -rf /var/cache/apk/*

RUN rm /usr/bin/tini

EXPOSE 9091 51413 51413/udp
VOLUME /opt/transmission/var/
WORKDIR /opt/transmission/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/transmission/
ENV PATH=/opt/transmission/bin:$PATH
