FROM alpine:edge

RUN echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

RUN apk update \
    && apk upgrade \
    && apk add \
        dockerize \
        nzbget@testing \
        tini \
        unrar \
    && rm -rf /var/cache/apk/*

RUN rm /usr/bin/tini

EXPOSE 6789
VOLUME /opt/nzbget/var/
WORKDIR /opt/nzbget/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/nzbget/

ENV PATH=/opt/nzbget/bin:$PATH
