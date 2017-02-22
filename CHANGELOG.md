### Release 17.2.0 (February 21, 2017)

- Download and use Java 8 for the gocd server and agent images.
- Use the environment variable GO_SERVER_URL while connecting the gocd agent with the gocd server.

#### Deprecations

- As of release 17.2.0, the old environment variables `GO_SERVER` and `GO_SERVER_PORT` are deprecated. They will be removed in release 17.3.0. Users are encouraged to use the environment variable `GO_SERVER_URL`.

