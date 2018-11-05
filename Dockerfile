FROM buildpack-deps:bionic

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Ruby build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            bzip2 \
            ca-certificates \
            gcc \
            libffi-dev \
            libgmp-dev \
            libssl-dev \
            libyaml-dev \
            make \
            procps \
            zlib1g-dev \
            unzip \
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

ADD ruby_build_dep.txt /tmp
ADD install_ruby.sh /tmp
RUN /tmp/install_ruby.sh

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
