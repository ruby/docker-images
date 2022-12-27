#! /bin/bash

set -ex

docker buildx build \
  --build-arg BASE_IMAGE_TAG=jammy \
  --build-arg RUBY_VERSION_MAJOR=3 \
  --build-arg RUBY_VERSION_MINOR=2 \
  --build-arg RUBY_VERSION_TEENY=0 \
  ${DOCKER_BUILDX_CACHE_FROM_DIR:+--cache-from type=local,src=$DOCKER_BUILDX_CACHE_FROM_DIR} \
  ${DOCKER_BUILDX_CACHE_TO_DIR:+--cache-to type=local,dest=$DOCKER_BUILDX_CACHE_TO_DIR} \
  --platform linux/amd64,linux/arm64 \
  --target ruby \
  --tag rubylang/ruby:3.2.0-jammy \
  --tag rubylang/ruby:3.2-jammy \
  --tag rubylang/ruby:latest \
  --tag ghcr.io/ruby/ruby:3.2.0-jammy \
  --tag ghcr.io/ruby/ruby:3.2-jammy \
  --tag ghcr.io/ruby/ruby:latest \
  -o type=local,dest=out \
  .

docker buildx build \
  --build-arg BASE_IMAGE_TAG=jammy \
  --build-arg RUBY_VERSION_MAJOR=3 \
  --build-arg RUBY_VERSION_MINOR=2 \
  --build-arg RUBY_VERSION_TEENY=0 \
  ${DOCKER_BUILDX_CACHE_FROM_DIR:+--cache-from type=local,src=$DOCKER_BUILDX_CACHE_FROM_DIR} \
  ${DOCKER_BUILDX_CACHE_TO_DIR:+--cache-to type=local,dest=$DOCKER_BUILDX_CACHE_TO_DIR} \
  --platform linux/amd64,linux/arm64 \
  --target development \
  --tag rubylang/ruby:3.2.0-dev-jammy \
  --tag rubylang/ruby:3.2-dev-jammy \
  --tag ghcr.io/ruby/ruby:3.2.0-dev-jammy \
  --tag ghcr.io/ruby/ruby:3.2-dev-jammy \
  -o type=local,dest=out \
  .
