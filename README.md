# ruby/ruby-docker-images

Built images are available here:
https://hub.docker.com/r/rubylang/ruby/

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
