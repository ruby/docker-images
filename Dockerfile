ARG BASE_IMAGE_TAG
ARG RUBY_VERSION
ARG RUBY_SO_SUFFIX

### build ###
FROM ubuntu:$BASE_IMAGE_TAG AS build

ARG BASE_IMAGE_TAG
ARG RUBY_VERSION

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN set -ex && \
    apt-get update && \
    \
    if test "x$BASE_IMAGE_TAG" = "xbionic"; then \
        apt-get install -y --no-install-recommends \
          software-properties-common && \
        apt-add-repository ppa:git-core/ppa; \
    fi && \
    \
    apt-get install -y --no-install-recommends \
            autoconf \
            bison \
            ca-certificates \
            dpkg-dev \
            gcc \
            git \
            g++ \
            libffi-dev \
            libgdbm-dev \
            libgmp-dev \
            libncurses5-dev \
            libreadline-dev \
            libssl-dev \
            libyaml-dev \
            make \
            ruby \
            rustc \
            tzdata \
            wget \
            xz-utils \
            zlib1g-dev \
            && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

COPY tmp/ruby /usr/src/ruby
COPY install_ruby.sh /tmp/

RUN set -ex && \
    RUBY_VERSION=3.2.3 PREFIX=/root /tmp/install_ruby.sh
RUN apt purge -y --auto-remove ruby
COPY tmp/ruby /usr/src/ruby

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
    PATH=/root/bin:$PATH /tmp/install_ruby.sh

### ruby ###
FROM ubuntu:$BASE_IMAGE_TAG AS ruby

ARG BASE_IMAGE_TAG
ARG RUBY_VERSION
ARG RUBY_SO_SUFFIX

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN set -ex && \
    apt-get update && \
    \
    if test "x$BASE_IMAGE_TAG" = "xbionic"; then \
        apt-get install -y --no-install-recommends \
                software-properties-common \
                && \
        apt-add-repository ppa:git-core/ppa; \
    fi && \
    \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            libffi-dev \
            libgdbm-dev \
            libgmp-dev \
            libncurses5-dev \
            libreadline-dev \
            libssl-dev \
            libyaml-dev \
            tzdata \
            zlib1g-dev \
            && \
    dpkg-query --show --showformat '${package}\n' \
      | grep -P '^(lib(ffi|gdbm|gmp|ncurses|readline|ssl|yaml)|zlib)' \
      | grep -v -P -- '-dev$' \
      | xargs apt-mark manual \
      && \
    apt-get purge -y --auto-remove \
            libffi-dev \
            libgdbm-dev \
            libgmp-dev \
            libncurses5-dev \
            libreadline-dev \
            libssl-dev \
            libyaml-dev \
            zlib1g-dev \
            && \
    \
    apt-get clean && rm -r /var/lib/apt/lists/*

RUN set -ex && \
    useradd -ms /bin/bash ubuntu

RUN mkdir -p /usr/local/etc

COPY --from=build \
     /usr/local/etc/gemrc /usr/local/etc

COPY --from=build \
     /usr/local/bin/bundle \
     /usr/local/bin/bundler \
     /usr/local/bin/erb \
     /usr/local/bin/gem \
     /usr/local/bin/irb \
     /usr/local/bin/racc \
     /usr/local/bin/rake \
     /usr/local/bin/rdoc \
     /usr/local/bin/ri \
     /usr/local/bin/ruby \
     /usr/local/bin/

COPY --from=build \
     /usr/local/etc/gemrc \
     /usr/local/etc/

COPY --from=build \
     /usr/local/include \
     /usr/local/include

COPY --from=build \
     /usr/local/lib/libruby.so.${RUBY_SO_SUFFIX:-$RUBY_VERSION} \
     /usr/local/lib/

RUN set -ex && \
    RUBY_SO_SUFFIX_MM=$(echo ${RUBY_SO_SUFFIX:-$RUBY_VERSION} | sed -e 's/\.[^.]\+$//') && \
    ln -sf libruby.so.${RUBY_SO_SUFFIX:-$RUBY_VERSION} /usr/local/lib/libruby.so.${RUBY_SO_SUFFIX_MM} && \
    ln -sf libruby.so.${RUBY_SO_SUFFIX:-$RUBY_VERSION} /usr/local/lib/libruby.so

COPY --from=build \
     /usr/local/lib/pkgconfig/ \
     /usr/local/lib/pkgconfig/

COPY --from=build \
     /usr/local/lib/ruby/ \
     /usr/local/lib/ruby/

COPY --from=build \
     /usr/local/share/man/man1/erb.1 \
     /usr/local/share/man/man1/irb.1 \
     /usr/local/share/man/man1/ri.1 \
     /usr/local/share/man/man1/ruby.1 \
     /usr/local/share/man/man1/


### development ###
FROM ruby AS development

RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
            build-essential \
            pkg-config \
            curl \
            gdb \
            git \
            less \
            lv \
            wget \
            && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*
