FROM golang:alpine3.15 as build-stage

RUN apk --update --no-cache add \
    git

RUN git clone --depth 1 --single-branch https://github.com/hacdias/webdav /src

RUN cd /src && go build -o bin/webdav

FROM alpine:3.15

ARG BUILD_DATE
ARG VERSION

LABEL build_version="catfight360.com version:${VERSION} Build-date:${BUILD_DATE}"
LABEL maintainer="VergilGao"
LABEL build_from="https://github.com/hacdias/webdav"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-webdav"

ENV TZ="Asia/Shanghai"
ENV UID=99
ENV GID=100
ENV UMASK=000

RUN apk --update  --no-cache add \
    shadow \
    tzdata

COPY --from=build-stage /src/bin/ /app
ADD docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh && \
    mkdir -p /data && \
    mkdir -p /config && \
    useradd -d /data -s /bin/sh alpha && \
    chown -R alpha /data

VOLUME [ "/data", "/config" ]

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]