#!/bin/bash

set -ex

RUBY_VERSION=${RUBY_VERSION-2.5.3}
RUBY_MAJOR=$(echo -n $RUBY_VERSION | sed -E 's/\.[0-9]+(-.*)?$//g')
RUBYGEMS_VERSION=${RUBYGEMS_VERSION-2.7.8}
BUNDLER_VERSION=${BUNDLER_VERSION-1.17.1}

case $RUBY_VERSION in
  trunk:*)
    RUBY_TRUNK_COMMIT=$(echo $RUBY_VERSION | awk -F: '{print $2}' )
    RUBY_VERSION=trunk
    ;;
  2.6.0-preview3)
    RUBY_DOWNLOAD_SHA256=9856d9e0e32df9e5cdf01928eec363d037f1a76dab2abbf828170647beaf64fe
    ;;
  2.6.0-preview2)
    RUBY_DOWNLOAD_SHA256=00ddfb5e33dee24469dd0b203597f7ecee66522ebb496f620f5815372ea2d3ec
    ;;
  2.5.3)
    RUBY_DOWNLOAD_SHA256=1cc9d0359a8ea35fc6111ec830d12e60168f3b9b305a3c2578357d360fcf306f
    ;;
  2.4.5)
    RUBY_DOWNLOAD_SHA256=2f0cdcce9989f63ef7c2939bdb17b1ef244c4f384d85b8531d60e73d8cc31eeb
    ;;
  2.3.8)
    RUBY_DOWNLOAD_SHA256=910f635d84fd0d81ac9bdee0731279e6026cb4cd1315bbbb5dfb22e09c5c1dfe
    ;;
  *)
    echo "Unsupported RUBY_VERSION ($RUBY_VERSION)" >2
    exit 1
    ;;
esac

case $RUBY_VERSION in
  2.3.*)
    # Need to down grade openssl to 1.0.x for Ruby 2.3.x
    apt-get install -y --no-install-recommends libssl1.0-dev
    ;;
esac
rm -rf /var/lib/apt/lists/*

if test -n "$RUBY_TRUNK_COMMIT"; then
  git clone https://github.com/ruby/ruby.git /usr/src/ruby
  cd /usr/src/ruby
  git checkout $RUBY_TRUNK_COMMIT
else
  wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.xz"
  echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c -
  mkdir -p /usr/src/ruby
  tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1
  rm ruby.tar.xz
fi

(
  cd /usr/src/ruby
  autoconf
  gnuArch=$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)
  ./configure \
    --build="$gnuArch" \
    --prefix=/usr/local \
    --disable-install-doc \
    --enable-shared \
    optflags="-O3 -mtune=native -march=native" \
    debugflags="-g3"

  make -j "$(nproc)"
  make install
)

if test $RUBY_VERSION != "trunk"; then
  gem update --system "$RUBYGEMS_VERSION"
fi

gem install bundler --version "$BUNDLER_VERSION" --force

rm -r /root/.gem/
