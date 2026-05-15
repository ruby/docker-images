# rubylang/ruby

Official Ruby Docker images maintained by the Ruby core team.

* Docker Hub: https://hub.docker.com/r/rubylang/ruby/
* GitHub Container Registry: https://github.com/ruby/docker-images/pkgs/container/ruby
* Source: https://github.com/ruby/docker-images

## Quick start

Pull the latest stable Ruby image and run it:

```
docker pull rubylang/ruby:4.0
docker run --rm rubylang/ruby:4.0 ruby -v
```

The `latest` tag points to the most recent stable release of the current latest series (4.0).

## What is this?

This repository provides two flavors of Ruby images for each supported version:

- **Production** (e.g. `rubylang/ruby:4.0-noble`): minimal image with Ruby and bundler installed.
- **Development** (e.g. `rubylang/ruby:4.0-dev-noble`): based on the production image, with `build-essential`, `gdb`, and other development tools added. The `-dev` suffix follows the version number.

The images listed below are based on Ubuntu noble, resolute, or jammy, and are built by running `make install` on the official Ruby source tarball. Unsuffixed tags such as `rubylang/ruby:4.0` and `rubylang/ruby:latest` currently track the noble images.

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
  - `rubylang/ruby:4.0.4-noble`
- 3.4
  - `rubylang/ruby:3.4-noble`
  - `rubylang/ruby:3.4.9-noble`
- 3.3
  - `rubylang/ruby:3.3-noble`
  - `rubylang/ruby:3.3.11-noble`

### Ubuntu 26.04 (resolute)

- master
  - `rubylang/ruby:master-resolute`
  - `rubylang/ruby:master-dev-resolute`
  - `rubylang/ruby:master-debug-resolute`
  - `rubylang/ruby:master-debug-dev-resolute`
- 4.0
  - `rubylang/ruby:4.0-resolute`
  - `rubylang/ruby:4.0.4-resolute`
- 3.4
  - `rubylang/ruby:3.4-resolute`
  - `rubylang/ruby:3.4.9-resolute`
- 3.3
  - `rubylang/ruby:3.3-resolute`
  - `rubylang/ruby:3.3.11-resolute`

### Ubuntu 22.04 (jammy)

- master
  - `rubylang/ruby:master-jammy`
  - `rubylang/ruby:master-dev-jammy`
  - `rubylang/ruby:master-debug-jammy`
  - `rubylang/ruby:master-debug-dev-jammy`
- 4.0
  - `rubylang/ruby:4.0-jammy`
  - `rubylang/ruby:4.0.4-jammy`
- 3.4
  - `rubylang/ruby:3.4-jammy`
  - `rubylang/ruby:3.4.9-jammy`
- 3.3
  - `rubylang/ruby:3.3-jammy`
  - `rubylang/ruby:3.3.11-jammy`

### Misc

Additional images are published for special purposes:

- Preview or release-candidate versions (e.g. `rubylang/ruby:4.0.0-preview2-noble`)
- Nightly builds of master (e.g. `rubylang/ruby:master-nightly-noble`)
- Nightly debug builds of master (e.g. `rubylang/ruby:master-debug-nightly-noble`)
- EOL versions, for compatibility use only (e.g. `rubylang/ruby:2.4.10-jammy`)

## Contributing

The Dockerfile and build scripts live in the [ruby/docker-images](https://github.com/ruby/docker-images) repository.

### Building locally

```
rake docker:build ruby_version=<Ruby version you want to build>
```

You can also specify a specific revision on the master branch:

```
rake docker:build ruby_version=master:ce798d08de
```

### Triggering a build

Builds can be triggered via GitHub Actions `workflow_dispatch`. Open the Actions tab, select the "Build Docker image with multi-arch" workflow, and run it with a `ruby_version` parameter (e.g. `3.4.9` or `master`).

### Scheduled builds

Scheduled builds run every 8 hours on GitHub Actions, at 00:15, 08:15, and 16:15 UTC (09:15, 17:15, and 01:15 JST).

## Author

Kenta Murata

## License

MIT
