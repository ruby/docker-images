# ruby/ruby-docker-images

The Dockerfile is available in [this repository](https://github.com/ruby/ruby-docker-images/blob/master/Dockerfile).

Built images are available here:

* https://hub.docker.com/r/rubylang/ruby/
* https://github.com/ruby/ruby-docker-images/pkgs/container/ruby

## What is this?

This repository consists of two kinds of images. One is for production use, and the other is for development.

An image for development is based on the image for production of the same ruby and ubuntu versions and installed development tools such as build-essential and gdb, in addition. It has `-dev` suffix after the version number, like `rubylang/ruby:3.3.0-dev-jammy`.

The list of image names in this repository is below:

## Images

### Ubuntu 22.04 (jammy)

- 3.3
  - rubylang/ruby:latest
  - rubylang/ruby:3.3-jammy
  - rubylang/ruby:3.3-dev-jammy
  - rubylang/ruby:3.3.0-jammy
  - rubylang/ruby:3.3.0-dev-jammy
- 3.2
  - rubylang/ruby:3.2-jammy
  - rubylang/ruby:3.2-dev-jammy
  - rubylang/ruby:3.2.3-jammy
  - rubylang/ruby:3.2.3-dev-jammy

### Ubuntu 20.04 (focal)

- 3.3
  - rubylang/ruby:3.3-focal
  - rubylang/ruby:3.3-dev-focal
  - rubylang/ruby:3.3.0-focal
  - rubylang/ruby:3.3.0-dev-focal
- 3.2
  - rubylang/ruby:3.2-focal
  - rubylang/ruby:3.2-dev-focal
  - rubylang/ruby:3.2.3-focal
  - rubylang/ruby:3.2.2-dev-focal
- 3.1
  - rubylang/ruby:3.1-focal
  - rubylang/ruby:3.1-dev-focal
  - rubylang/ruby:3.1.4-focal
  - rubylang/ruby:3.1.4-dev-focal
- 3.0
  - rubylang/ruby:3.0-focal
  - rubylang/ruby:3.0-dev-focal
  - rubylang/ruby:3.0.6-focal
  - rubylang/ruby:3.0.6-dev-focal

### Misc

We have some other images for special purposes.

- Preview or Release-candidate versions (e.g. `rubylang/ruby:2.7.0-preview1-bionic`)
- Nightly built master (e.g. `rubylang/ruby:master-nightly-bionic`)
- Nightly debug built master (e.g. `rubylang/ruby:master-debug-nightly-bionic`)
- EOL versions (e.g. `rubylang/ruby:2.4.10-bionic`)

All the images are based on `ubuntu:bionic`, and made from just doing `make install` and installing bundler.

## How to build images

```
rake docker:build ruby_version=<Ruby version you want to build>
```

You can specify the specific revision in the master branch like:

```
rake docker:build ruby_version=master:ce798d08de
```

## Build and push for the specific ruby and ubuntu versions

Trigger CircleCI workflow with `ruby_version` and `ubuntu_version` pipeline parameters.
Nightly build workflow is triggered if the workflow triggered with `ruby_version` of `"nightly"`.
The nightly build workflow only builds images of linux/amd64 platform.

## Nightly build workflow

Nightly build workflow is performed by CircleCI's scheduled pipeline system.
The build is triggered at 16:00 UTC (01:00 JST) every night.

## Author

Kenta Murata

## License

MIT
