# ruby/docker-images

The Dockerfile is available in [this repository](https://github.com/ruby/ruby-docker-images/blob/master/Dockerfile).

Built images are available here:

* https://hub.docker.com/r/rubylang/ruby/
* https://github.com/ruby/ruby-docker-images/pkgs/container/ruby

## What is this?

This repository consists of two kinds of images. One is for production use, and the other is for development.

An image for development is based on the image for production of the same ruby and ubuntu versions and installed development tools such as build-essential and gdb, in addition. It has `-dev` suffix after the version number, like `rubylang/ruby:3.3.0-dev-noble`.

The list of image names in this repository is below:

## Images

### Ubuntu 24.04 (noble)

- master
  - `rubylang/ruby:master-noble`
  - `rubylang/ruby:master-dev-noble`
  - `rubylang/ruby:master-debug-noble`
  - `rubylang/ruby:master-debug-dev-noble`
- 4.0
  - **`rubylang/ruby:latest`**
  - `rubylang/ruby:4.0-noble`
  - `rubylang/ruby:4.0.0-noble`
- 3.4
  - `rubylang/ruby:3.4-noble`
  - `rubylang/ruby:3.4.8-noble`
- 3.3
  - `rubylang/ruby:3.3-noble`
  - `rubylang/ruby:3.3.10-noble`
- 3.2
  - `rubylang/ruby:3.2-noble`
  - `rubylang/ruby:3.2.9-noble`
- 3.1
  - `rubylang/ruby:3.1-noble`
  - `rubylang/ruby:3.1.7-noble`

### Ubuntu 22.04 (jammy)

- master
  - `rubylang/ruby:master-jammy`
  - `rubylang/ruby:master-dev-jammy`
  - `rubylang/ruby:master-debug-jammy`
  - `rubylang/ruby:master-debug-dev-jammy`
- 4.0
  - `rubylang/ruby:4.0-jammy`
  - `rubylang/ruby:4.0.0-jammy`
- 3.4
  - `rubylang/ruby:3.4-jammy`
  - `rubylang/ruby:3.4.8-jammy`
- 3.3
  - `rubylang/ruby:3.3-jammy`
  - `rubylang/ruby:3.3.10-jammy`
- 3.2
  - `rubylang/ruby:3.2-jammy`
  - `rubylang/ruby:3.2.9-jammy`
- 3.1
  - `rubylang/ruby:3.1-jammy`
  - `rubylang/ruby:3.1.7-jammy`

### Misc

We have some other images for special purposes.

- Preview or Release-candidate versions (e.g. `rubylang/ruby:2.7.0-preview1-jammy`)
- Nightly built master (e.g. `rubylang/ruby:master-nightly-jammy`)
- Nightly debug built master (e.g. `rubylang/ruby:master-debug-nightly-jammy`)
- EOL versions (e.g. `rubylang/ruby:2.4.10-jammy`)

All the images are based on `ubuntu:jammy`, and made from just doing `make install` and installing bundler.

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
