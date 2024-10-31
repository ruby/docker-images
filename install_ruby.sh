#!/bin/bash

set -ex

RUBY_VERSION=${RUBY_VERSION-2.6.0}
RUBY_MAJOR=$(echo $RUBY_VERSION | sed -E 's/\.[0-9]+(-.*)?$//g')
RUBYGEMS_VERSION=${RUBYGEMS_VERSION-3.2.3}
PREFIX=${PREFIX-/usr/local}

function get_released_ruby() {
  cat << RUBY | ruby - $1
require "net/http"
require "uri"
require "open-uri"
require "digest"
ver2 = ARGV[0].split('.')[0,2].join('.')
if Net::HTTP.get_response(URI.parse("https://cache.ruby-lang.org/pub/ruby/#{ver2}/ruby-#{ARGV[0]}.tar.xz")).code == "200"
  url = "https://cache.ruby-lang.org/pub/ruby/#{ver2}/ruby-#{ARGV[0]}.tar.xz"
  URI.open(url) do |f|
    sha256 = Digest::SHA256.hexdigest(f.read)
    puts "#{url} #{sha256}"
  end
else
  exit 1
end
RUBY
}

case $RUBY_VERSION in
  master)
    RUBY_MASTER_COMMIT=
    ;;
  master:*)
    RUBY_MASTER_COMMIT=$(echo $RUBY_VERSION | awk -F: '{print $2}' )
    RUBY_VERSION=master
    ;;
  *)
    read RUBY_DOWNLOAD_URI RUBY_DOWNLOAD_SHA256 < <(get_released_ruby $RUBY_VERSION)
    if test -z "$RUBY_DOWNLOAD_URI"; then
      echo "Unsupported RUBY_VERSION ($RUBY_VERSION)" >2
      exit 1
    fi
    echo $RUBY_DOWNLOAD_URI
    echo $RUBY_DOWNLOAD_SHA256
    ;;
esac

case $RUBY_VERSION in
  2.3.*)
    # Need to down grade openssl to 1.0.x for Ruby 2.3.x
    apt-get install -y --no-install-recommends libssl1.0-dev
    ;;
esac

if test -n "$RUBY_MASTER_COMMIT"; then
  if test -f /usr/src/ruby/configure.ac; then
    cd /usr/src/ruby
    git pull --rebase origin
  else
    rm -r /usr/src/ruby
    git clone https://github.com/ruby/ruby.git /usr/src/ruby
    cd /usr/src/ruby
  fi
  git checkout $RUBY_MASTER_COMMIT
else
  if test -z "$RUBY_DOWNLOAD_URI"; then
    RUBY_DOWNLOAD_URI="https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.xz"
  fi
  wget -O ruby.tar.xz $RUBY_DOWNLOAD_URI
  echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c -
  mkdir -p /usr/src/ruby
  tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1
  rm ruby.tar.xz
fi

(
  cd /usr/src/ruby

  if test ! -x ./configure; then
    if test -x ./autogen.sh; then
      ./autogen.sh
    else
      autoconf
    fi
  fi

  mkdir -p /tmp/ruby-build
  pushd /tmp/ruby-build

  gnuArch=$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)
  configure_args=( \
    --build="$gnuArch" \
    --prefix="$PREFIX" \
    --disable-install-doc \
    --enable-shared \
    --enable-yjit
  )

  if [ -n "$cppflags" ]; then
    export cppflags=$cppflags
  else
    unset cppflags
  fi

  if [ -n "$optflags" ]; then
    export optflags=$optflags
  else
    unset optflags
  fi

  if [ -n "$debugflags" ]; then
    export debugflags=$debugflags
  else
    unset debugflags
  fi

  /usr/src/ruby/configure "${configure_args[@]}" || {
    cat config.log | grep flags=
    exit 1
  }

  make -j "$(nproc)"
  make install

  popd
  rm -rf /tmp/ruby-build
)

rm -fr /usr/src/ruby /root/.gem/

# rough smoke test
export PATH=$PREFIX/bin:$PATH
(cd && ruby --version && gem --version && bundle --version)
