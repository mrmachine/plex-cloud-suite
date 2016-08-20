FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        bash \
        dockerize \
        git \
        py-cryptography \
        py-lxml \
        py-openssl \
        py-pip \
        python \
        tini \
    && rm -rf /var/cache/apk/*
RUN rm /usr/bin/tini

EXPOSE 5050
VOLUME /opt/couchpotatoserver/src/ /opt/couchpotatoserver/var/
WORKDIR /opt/couchpotatoserver/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/couchpotatoserver/
ENV PATH=/opt/couchpotatoserver/bin:$PATH
