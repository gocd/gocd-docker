# Build stable release using: docker build --build-arg GO_VERSION=16.0-xxxx -t gocd-server .
# Build experimental release using: docker build --build-arg GO_VERSION=16.0-xxxx  --build-arg DOWNLOAD_URL=https://download.gocd.io/experimental/binaries -t gocd-server .

FROM phusion/baseimage:0.9.18
MAINTAINER GoCD <go-cd-dev@googlegroups.com>

ARG GO_VERSION="16.8.0-3929"
ARG DOWNLOAD_URL="https://download.gocd.io/binaries"

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh \
    && add-apt-repository -y ppa:openjdk-r/ppa \
    && apt-get update \
    && apt-get install -y -q unzip openjdk-8-jre-headless git mercurial subversion \
    && mkdir /etc/service/go-server

ADD go-common-scripts.sh /etc/service/go-server/go-common-scripts.sh
ADD go-server-start.sh /etc/service/go-server/run

ADD $DOWNLOAD_URL/$GO_VERSION/deb/go-server_${GO_VERSION}_all.deb /tmp/go-server.deb

RUN groupadd -r go \
    && useradd -r -c "Go User" -g "go" -d "/var/go" -m -s "/bin/bash" go \
    && mkdir -p /var/lib/go-server/addons /var/log/go-server /etc/go /go-addons /plugins /var/lib/go-server/plugins \
    && ln -sf /plugins /var/lib/go-server/plugins/external \
    && chown -R go:go /var/lib/go-server /var/log/go-server /etc/go /go-addons /var/go /plugins

WORKDIR /tmp
RUN dpkg -i --debug=10 /tmp/go-server.deb \
    && sed -i -e 's/DAEMON=Y/DAEMON=N/' /etc/default/go-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/var/lib/go-server", "/var/log/go-server", "/etc/go", "/go-addons", "/var/go"]

EXPOSE 8153 8154

CMD ["/sbin/my_init"]
