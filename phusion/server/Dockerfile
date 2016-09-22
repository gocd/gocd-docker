# Build stable release using: docker build --build-args GO_VERSION=16.0-xxxx -t gocd-server .
# Build experimental release using: docker build --build-args GO_VERSION=16.0-xxxx  --build-args DOWNLOAD_URL=https://download.go.cd/experimental/binaries -t gocd-server .

FROM phusion/baseimage:0.9.18
MAINTAINER GoCD <go-cd-dev@googlegroups.com>

ARG GO_VERSION="16.8.0-3929"
ARG DOWNLOAD_URL="https://download.go.cd/binaries"

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y -q unzip openjdk-7-jre-headless git mercurial subversion

RUN mkdir /etc/service/go-server
ADD go-common-scripts.sh /etc/service/go-server/go-common-scripts.sh
ADD go-server-start.sh /etc/service/go-server/run

ADD $DOWNLOAD_URL/$GO_VERSION/deb/go-server_${GO_VERSION}_all.deb /tmp/go-server.deb

RUN ["groupadd", "-r", "go"]
RUN ["useradd", "-r", "-c", "Go User", "-g", "go", "-d", "/var/go", "-m", "-s", "/bin/bash", "go"]
RUN ["mkdir", "-p", "/var/lib/go-server/addons", "/var/log/go-server", "/etc/go", "/go-addons"]
RUN ["chown", "-R", "go:go", "/var/lib/go-server", "/var/log/go-server", "/etc/go", "/go-addons", "/var/go"]
VOLUME ["/var/lib/go-server", "/var/log/go-server", "/etc/go", "/go-addons", "/var/go"]

WORKDIR /tmp
RUN dpkg -i --debug=10 /tmp/go-server.deb
RUN sed -i -e 's/DAEMON=Y/DAEMON=N/' /etc/default/go-server
EXPOSE 8153 8154

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
