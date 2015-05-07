# Build using: docker build -f Dockerfile.gocd-server -t gocd-server:14.4.0 .
FROM phusion/baseimage:0.9.16
MAINTAINER Aravind SV <arvind.sv@gmail.com>

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get update && apt-get install -y -q unzip openjdk-7-jre-headless git
# Due to a bug, it looks like you cannot create a pipeline if you're physically located west of the server. Hmm. :(
RUN echo Pacific/Samoa > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir /etc/service/go-server
ADD gocd-server/go-common-scripts.sh /etc/service/go-server/go-common-scripts.sh
ADD gocd-server/go-server-start.sh /etc/service/go-server/run

ADD http://download.go.cd/local/15.1.0-1732/go-server-15.1.0-1732.deb /tmp/go-server.deb

RUN ["groupadd", "-r", "go"]
RUN ["useradd", "-r", "-c", "Go User", "-g", "go", "-d", "/var/go", "-m", "-s", "/bin/bash", "go"]
RUN ["mkdir", "-p", "/var/lib/go-server/addons", "/var/log/go-server", "/etc/go", "/go-addons"]
RUN ["touch", "/etc/go/postgresqldb.properties"]
RUN ["chown", "-R", "go:go", "/var/lib/go-server", "/var/log/go-server", "/etc/go", "/go-addons"]
VOLUME ["/var/lib/go-server", "/var/log/go-server", "/etc/go", "/go-addons"]

WORKDIR /tmp
RUN dpkg -i --debug=10 /tmp/go-server.deb
RUN sed -i -e 's/DAEMON=Y/DAEMON=N/' /etc/default/go-server
EXPOSE 8153 8154

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
