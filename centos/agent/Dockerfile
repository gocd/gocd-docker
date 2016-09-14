# docker build --build-arg GO_VERSION=16.x.x-xxxx --rm -t gocd-agent . 
FROM centos:7
MAINTAINER "GoCD" <gocd-dev@googlegroups.com>

ARG GO_VERSION="16.8.0-3929"
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


ADD https://download.go.cd/experimental/binaries/$GO_VERSION/rpm/go-agent-$GO_VERSION.noarch.rpm /tmp/go-agent.rpm

WORKDIR /tmp
RUN yum install -y /tmp/go-agent.rpm; yum clean all; rm -f /etc/default/go-server

# Run your program under Tini
CMD PRODUCTION_MODE=N /usr/share/go-agent/agent.sh
