FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        bash \
        dockerize \
        git \
        python \
        py-babel \
        py-pip \
        py-lxml \
        tini \
    && rm -rf /var/cache/apk/*

RUN rm /usr/bin/tini

EXPOSE 8081
VOLUME /opt/sickrage/src/ /opt/sickrage/var/
WORKDIR /opt/sickrage/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/sickrage/

ENV PATH=/opt/sickrage/bin:$PATH
