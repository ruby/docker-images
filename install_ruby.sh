#!/bin/bash

set -ex

RUBY_VERSION=${RUBY_VERSION-2.6.0}
RUBY_MAJOR=$(echo $RUBY_VERSION | sed -E 's/\.[0-9]+(-.*)?$//g')
RUBYGEMS_VERSION=${RUBYGEMS_VERSION-3.0.3}

function get_released_ruby() {
  rm -rf /tmp/www
  git clone --depth 1 https://github.com/ruby/www.ruby-lang.org.git /tmp/www

  cat << RUBY | ruby - $1 /tmp/www/_data/releases.yml
require "psych"
version = ARGV[0]
releases = Psych.load_file(ARGV[1])
release = releases.find {|x| x["version"] == version }
puts "#{release["url"]["xz"]} #{release["sha256"]["xz"]}"
RUBY
}

case $RUBY_VERSION in
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
  autoconf

  mkdir -p /tmp/ruby-build
  pushd /tmp/ruby-build

  gnuArch=$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)
  /usr/src/ruby/configure \
    --build="$gnuArch" \
    --prefix=/usr/local \
    --disable-install-doc \
    --enable-shared \
    ${cppflags:+cppflags="${cppflags}"} \
    ${optflags:+optflags="${debugflags}"} \
    optflags="${optflags:--O3}" \
    ${debugflags:+debugflags="${debugflags}"}

  make -j "$(nproc)"
  make install

  popd
  rm -rf /tmp/ruby-build
)

case $RUBY_VERSION in
  master)
    # DO NOTHING
    ;;
  2.7.*)
    # DO NOTHING
    ;;
  2.6.*)
    # DO NOTHING
    ;;
  *)
    gem update --system "$RUBYGEMS_VERSION"
    ;;
esac

rm -fr /usr/src/ruby /root/.gem/

# rough smoke test
(cd && ruby --version && gem --version && bundle --version)
