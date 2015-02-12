# Build using: docker build -f Dockerfile.docker-agent -t gocd-agent:14.4.0 .
FROM phusion/baseimage:0.9.16
MAINTAINER Aravind SV <arvind.sv@gmail.com>

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get update && apt-get install -y -q unzip openjdk-7-jre-headless git

RUN mkdir /etc/service/go-agent
ADD gocd-agent/go-agent-start.sh /etc/service/go-agent/run

ADD http://download.go.cd/gocd-deb/go-agent-14.4.0-1356.deb /tmp/go-agent.deb

WORKDIR /tmp
RUN dpkg -i /tmp/go-agent.deb
RUN sed -i -e 's/DAEMON=Y/DAEMON=N/' /etc/default/go-agent /etc/default/go-agent

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
