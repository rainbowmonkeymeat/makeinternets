ARG ALPINE_VERSION=3.19.1
ARG NGINX_VERSION=1.25.4
ARG HUGOVERSION=0.122.0
FROM alpine:${ALPINE_VERSION} AS builder

# Content below mostly from <https://github.com/jguyomard/docker-hugo/blob/c05479feeafd4eb2f9fc97a94834ac8f05b5a8db/Dockerfile>
#  with some modifications for my site

ARG GIT_HASH
ARG VERSION
ARG RELEASE_DATE
LABEL maintainer="Steve Miller <me@r15cookie.com>"
LABEL version="${VERSION}"
LABEL git_hash="${GIT_HASH}"
LABEL release-date="${RELEASE_DATE}"

RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync

ENV HUGOVERSION=${HUGOVERSION:-0.122.0}
RUN mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGOVERSION}/hugo_${HUGOVERSION}_Linux-64bit.tar.gz | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src
COPY . /src
RUN hugo --buildFuture


# Build actual HTML serving directory
FROM nginx:${NGINX_VERSION}
COPY --from=builder /src/public /usr/share/nginx/html