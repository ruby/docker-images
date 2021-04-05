ARG BASE_IMAGE_TAG=focal
FROM ubuntu:$BASE_IMAGE_TAG

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

ADD ruby_build_deps.txt /tmp/

RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      software-properties-common && \
    apt-add-repository ppa:git-core/ppa && \
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
            zlib1g-dev \
            $(cat /tmp/ruby_build_deps.txt) && \
            apt-get clean && rm -r /var/lib/apt/lists/*

RUN set -ex && \
    useradd -ms /bin/bash ubuntu

ADD tmp/ruby /usr/src/ruby
ADD install_ruby.sh /tmp/

ARG RUBY_VERSION=2.6.3
ENV RUBY_VERSION=$RUBY_VERSION
ENV RUBYGEMS_VERSION=3.2.3

ARG optflags
ARG debugflags
ARG cppflags

RUN set -ex && \
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
    rm /tmp/ruby_build_deps.txt

