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

## How to build images of 64bit ARM architecture

If you specify `arch=arm64` option to the rake task, you can build images of 64bit ARM architecture:

```
rake docker:build arch=arm64 ruby_version=<Ruby version you want to build>
```

The default value of the `arch` option is `amd64`.

## Author

Kenta Murata

## License

MIT
