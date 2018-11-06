FROM ubuntu:bionic

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Ruby build dependencies
RUN apt-get update && \
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
            && \
    rm -rf /var/lib/apt/lists/*

# skip installing gem documentation
RUN mkdir -p /usr/local/etc && \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

ARG RUBY_VERSION=2.5.1
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
    apt-get update && \
    apt-get install -y --no-install-recommends $buildDeps && \
    \
    /tmp/install_ruby.sh && \
    rm /tmp/install_ruby.sh && \
    \
    apt-get purge -y --auto-remove $buildDeps
