# Build stable release using:  docker build --build-arg GO_VERSION=16.x.x-xxxx --rm -t gocd-agent .
# Build experimental release using: docker build --build-arg GO_VERSION=16.x.x-xxxx --build-arg DOWNLOAD_URL=https://download.gocd.io/experimental/binaries --rm -t gocd-agent .
FROM centos:7
MAINTAINER "GoCD" <gocd-dev@googlegroups.com>

ARG GO_VERSION="16.8.0-3929"
ARG DOWNLOAD_URL="https://download.gocd.io/binaries"
ENV TINI_VERSION v0.9.0

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*; \
yum install -y java-1.8.0-openjdk-headless git;

VOLUME [ "/sys/fs/cgroup" ]

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]


ADD $DOWNLOAD_URL/$GO_VERSION/rpm/go-agent-$GO_VERSION.noarch.rpm /tmp/go-agent.rpm

WORKDIR /tmp
RUN yum install -y /tmp/go-agent.rpm; yum clean all; rm -f /etc/default/go-server

# Run your program under Tini
CMD PRODUCTION_MODE=N /usr/share/go-agent/agent.sh
