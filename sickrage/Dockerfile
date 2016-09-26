FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
        bash \
        dockerize \
        git \
        python2 \
        py-babel \
        py2-pip \
        py2-lxml \
        tini \
    && rm -rf /var/cache/apk/*
RUN rm /usr/bin/tini

EXPOSE 8081
WORKDIR /opt/sickrage/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/sickrage/
ENV PATH=/opt/sickrage/bin:$PATH
