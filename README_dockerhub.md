**THIS REPOSITORY IS CURRENTLY EXPERIMENTAL**

This repository consists of two kinds of images.  One is for production use, and the other is for development.  An image for development is based on the image for production of the same ruby and ubuntu versions and installed development tools such as build-essential and gdb, in addition.  It has `-dev` suffix after the version number, like `rubylang/ruby:3.2.0-dev-jammy`.

The list of image names in this repository is below:

- Stable released versions
    - 3.2
      - rubylang/ruby:3.2.0-jammy (== rubylang/ruby:3.2-jammy == rubylang/ruby:latest)
      - rubylang/ruby:3.2.0-dev-jammy (== rubylang/ruby:3.2-dev-jammy)
      - rubylang/ruby:3.2.0-focal (== rubylang/ruby:3.2-focal)
      - rubylang/ruby:3.2.0-dev-focal (== rubylang/ruby:3.2-dev-focal)
    - 3.1
      - rubylang/ruby:3.1.3-focal (== rubylang/ruby:3.1-focal)
      - rubylang/ruby:3.1.3-dev-focal (== rubylang/ruby:3.1-dev-focal)
      - rubylang/ruby:3.1.2-focal
      - rubylang/ruby:3.1.1-focal
      - rubylang/ruby:3.1.0-focal
    - 3.0
      - rubylang/ruby:3.0.5-focal (== rubylang/ruby:3.0-focal)
      - rubylang/ruby:3.0.5-dev-focal (== rubylang/ruby:3.0-dev-focal)
      - rubylang/ruby:3.0.4-focal
      - rubylang/ruby:3.0.3-focal
      - rubylang/ruby:3.0.2-focal
      - rubylang/ruby:3.0.1-focal
      - rubylang/ruby:3.0.0-focal
    - 2.7
      - rubylang/ruby:2.7.7-bionic (== rubylang/ruby:2.7-bionic)
      - rubylang/ruby:2.7.7-dev-bionic (== rubylang/ruby:2.7-dev-bionic)
      - rubylang/ruby:2.7.6-bionic
      - rubylang/ruby:2.7.5-bionic
      - rubylang/ruby:2.7.4-bionic
      - rubylang/ruby:2.7.3-bionic
      - rubylang/ruby:2.7.2-bionic
      - rubylang/ruby:2.7.1-bionic
      - rubylang/ruby:2.7.0-bionic

- Versions that passed their EOLs
    - 2.6
      - rubylang/ruby:2.6.10-bionic (== rubylang/ruby:2.6-bionic == rubylang/ruby:2.6)
      - rubylang/ruby:2.6.9-bionic
      - rubylang/ruby:2.6.8-bionic
      - rubylang/ruby:2.6.7-bionic
      - rubylang/ruby:2.6.6-bionic
      - rubylang/ruby:2.6.5-bionic
      - rubylang/ruby:2.6.4-bionic
      - rubylang/ruby:2.6.3-bionic
      - rubylang/ruby:2.6.2-bionic
      - rubylang/ruby:2.6.1-bionic
      - rubylang/ruby:2.6.0-bionic
    - 2.5
      - rubylang/ruby:2.5.8-bionic (== rubylang/ruby:2.5-bionic == rubylang/ruby:2.5)
      - rubylang/ruby:2.5.7-bionic
      - rubylang/ruby:2.5.6-bionic
      - rubylang/ruby:2.5.5-bionic
      - rubylang/ruby:2.5.4-bionic
      - rubylang/ruby:2.5.3-bionic
    - 2.4
      - rubylang/ruby:2.4.9-bionic (== rubylang/ruby:2.4-bionic == rubylang/ruby:2.4)
      - rubylang/ruby:2.4.8-bionic
      - rubylang/ruby:2.4.7-bionic
      - rubylang/ruby:2.4.6-bionic
      - rubylang/ruby:2.4.5-bionic
    - 2.3
      - rubylang/ruby:2.3.8-bionic (== rubylang/ruby:2.3-bionic == rubylang/ruby:2.3)
- Preview released versions (e.g. `rubylang/ruby:2.7.0-preview1-bionic`)
- Release-candidate versions
- Nightly built master (e.g. `rubylang/ruby:master-nightly-bionic`)
- Nightly debug built master (e.g. `rubylang/ruby:master-debug-nightly-bionic`)

All the images are based on `ubuntu:bionic`, and made from just doing `make install` and installing bundler.

The Dockerfile is available in [this repository](https://github.com/ruby/ruby-docker-images).