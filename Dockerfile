    
FROM alpine:edge

ENV LEANOTE_VERSION=2.6.1

RUN apk add --no-cache --update wget ca-certificates \
    && wget https://jaist.dl.sourceforge.net/project/leanote-bin/${LEANOTE_VERSION}/leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz \
    && tar -zxf leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz -C / \
    && apk del --purge wget \
	&& rm leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz

RUN mkdir -p /leanote/data/public/upload \
    && mkdir -p /leanote/data/files \
    && rm -r /leanote/public/upload \
    && rm -r /leanote/mongodb_backup \
    && ln -s /leanote/data/public/upload /leanote/public/upload \
    && ln -s /leanote/data/files /leanote/files \
    && chmod +x /leanote/bin/run.sh
	
RUN hash=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-64};echo;); \
    sed -i "s/app.secret=.*$/app.secret=$hash #/" /leanote/conf/app.conf; \
    sed -i "s/db.host=.*$/db.host=10.1.251.164/" /leanote/conf/app.conf; \
    sed -i "s/db.port=.*$/db.port=27017/" /leanote/conf/app.conf; \
    sed -i "s/site.url=.*$/site.url=\${SITE_URL} /" /leanote/conf/app.conf;

VOLUME /leanote/data/

EXPOSE 9000
WORKDIR  /leanote/bin
ENTRYPOINT ["sh", "run.sh"]
