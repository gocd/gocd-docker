### Release 17.2.0 (February 21, 2017)

- Download and use Java 8 for the gocd server and agent images.
- Use the environment variable GO_SERVER_URL while connecting the gocd agent with the gocd server.
    
    * Usage: `docker run -it -e GO_SERVER_URL=https://<ip_of_go_server>:<go_server_ssl_port>/go gocd/gocd-agent`
    
    * Usually, the go server ssl port is 8154. You can check the environment variable `GO_SERVER_SSL_PORT` in the GoCD server machine.

#### Deprecations

- As of docker release 17.2.0, the old environment variables `GO_SERVER` and `GO_SERVER_PORT` are deprecated. They will be removed in release 17.3.0. Users are encouraged to use the environment variable `GO_SERVER_URL`.

