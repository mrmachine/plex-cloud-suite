FROM alpine:edge

RUN apk update \
    && apk upgrade \
    && apk add \
		bash \
		certbot \
		nginx \
		tini \
	&& rm -rf /var/cache/apk/*
RUN rm /usr/bin/tini

RUN ln -s /opt/letsencrypt/bin/update-certs.sh /etc/periodic/daily/

ENV PATH="/opt/letsencrypt/bin:$PATH"

EXPOSE 80
VOLUME /etc/letsencrypt

ENTRYPOINT ["tini", "--", "entrypoint.sh"]
CMD ["run.sh"]

COPY . /opt/letsencrypt/
