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

## Author

Kenta Murata

## License

MIT
