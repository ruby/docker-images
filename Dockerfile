FROM ubuntu:bionic

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

ARG RUBY_VERSION=2.5.3
ENV RUBY_VERSION=$RUBY_VERSION
ENV RUBYGEMS_VERSION=2.7.8
ENV BUNDLER_VERSION=1.17.1

ADD install_ruby.sh /tmp
RUN set -ex && \
    \
    buildDeps='autoconf \
               bison \
               dpkg-dev \
               git-core \
               ruby \
               wget \
               xz-utils'; \
    \
    apt-get update && \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            gcc \
            libffi-dev \
            libgdbm-dev \
            libgmp-dev \
            libncurses5-dev \
            libreadline-dev \
            libssl-dev \
            libyaml-dev \
            make \
            tzdata \
            zlib1g-dev \
            $buildDeps && \
    \
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
    apt-get purge -y --auto-remove $buildDeps && \
    \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
