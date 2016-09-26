FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        bash \
        dockerize \
        git \
        py2-cryptography \
        py2-lxml \
        py2-openssl \
        py2-pip \
        python2 \
        tini \
    && rm -rf /var/cache/apk/*
RUN rm /usr/bin/tini

EXPOSE 5050
WORKDIR /opt/couchpotatoserver/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/couchpotatoserver/
ENV PATH=/opt/couchpotatoserver/bin:$PATH
