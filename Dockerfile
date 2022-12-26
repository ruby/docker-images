ARG BASE_IMAGE_TAG=jammy
ARG RUBY_VERSION=3.2.0

FROM ubuntu:$BASE_IMAGE_TAG as build

ARG BASE_IMAGE_TAG
ARG RUBY_VERSION

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

COPY ruby_build_deps.txt /tmp/

RUN set -ex && \
    apt-get update && \
    if [[ "$BASE_IMAGE_TAG" == "bionic" ]]; then \
        apt-get install -y --no-install-recommends \
          software-properties-common && \
        apt-add-repository ppa:git-core/ppa; \
    fi && \
    apt-get clean && rm -r /var/lib/apt/lists/*

RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            gcc \
            g++ \
            libffi-dev \
            libgdbm-dev \
            libgmp-dev \
            libncurses5-dev \
            libreadline-dev \
            libssl-dev \
            libyaml-dev \
            make \
            autoconf \
            bison \
            git \
            tzdata \
            zlib1g-dev && \
            apt-get clean && rm -r /var/lib/apt/lists/*

RUN set -ex && \
    useradd -ms /bin/bash ubuntu

COPY tmp/ruby /usr/src/ruby
COPY install_ruby.sh /tmp/

ENV RUBY_VERSION=$RUBY_VERSION
ENV RUBYGEMS_VERSION=3.2.3

ARG optflags
ARG debugflags
ARG cppflags

RUN apt-get update && \
    apt-get install -y --no-install-recommends $(cat /tmp/ruby_build_deps.txt) && \
    set -ex && \
# skip installing gem documentation
    mkdir -p /usr/local/etc && \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc && \
    \
    /tmp/install_ruby.sh && \
    rm /tmp/install_ruby.sh && \
    \
    dpkg-query --show --showformat '${package}\n' \
      | grep -P '^libreadline\d+$' \
      | xargs apt-mark manual && \
    \
    apt-get purge -y --auto-remove $(cat /tmp/ruby_build_deps.txt) && \
    apt-get clean && rm -r /var/lib/apt/lists/* && \
    rm /tmp/ruby_build_deps.txt


# FROM ubuntu:$BASE_IMAGE_TAG as ruby
ARG BASE_IMAGE_TAG
ARG RUBY_VERSION

# Copy Ruby from rubylang/ruby

COPY --from=build:$RUBY_VERSION-$BASE_IMAGE_TAG \
     /opt/ruby/bin /usr/local/bin/

COPY --from=build:$RUBY_VERSION-$BASE_IMAGE_TAG \
     /usr/local/etc/gemrc \
     /usr/local/etc/

# NOTE: DO NOT CHANGE the version in the path of include directory
COPY --from=build:$RUBY_VERSION-$BASE_IMAGE_TAG \
     /usr/local/include/ruby-3.2.0/ \
     /usr/local/include/ruby-3.2.0/
