FROM alpine:edge

RUN echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk update \
    && apk upgrade \
    && apk add \
        dockerize \
        ffmpeg \
        git \
        nzbget@testing \
        p7zip \
        python \
        tini \
        unrar \
    && rm -rf /var/cache/apk/*
RUN rm /usr/bin/tini

EXPOSE 6789
WORKDIR /opt/nzbget/

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh", "run.sh"]

COPY . /opt/nzbget/
ENV PATH=/opt/nzbget/bin:$PATH
