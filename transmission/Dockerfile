FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        bash \
        bc \
        dockerize \
        jq \
        python \
        py-pip \
        transmission-cli \
        transmission-daemon \
        tini \
    && rm -rf /var/cache/apk/*
RUN pip install --no-cache-dir hardlink
RUN rm /usr/bin/tini

EXPOSE 9091 51413 51413/udp
VOLUME /opt/transmission/var/
WORKDIR /opt/transmission/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/transmission/
ENV PATH=/opt/transmission/bin:$PATH
