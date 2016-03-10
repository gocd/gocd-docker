#!/bin/bash

AGENT_KEY=${AGENT_KEY:-123456789abcdef}

export GO_SERVER=${GO_SERVER:-go-server}
export GO_SERVER_PORT=8153
export DAEMON=${DAEMON:-N}
export AGENT_WORK_DIR=/var/lib/go-agent
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre

mkdir -p /var/lib/go-agent/config /var/run/go-agent /var/log/go-agent
chown -R go:go /var/lib/go-agent/config /var/run/go-agent /var/log/go-agent

rm -f /etc/default/go-agent

autoregister_file=/var/lib/go-agent/config/autoregister.properties
echo "agent.auto.register.key=$AGENT_KEY" >$autoregister_file
if [ -n "$AGENT_RESOURCES" ]; then echo "agent.auto.register.resources=$AGENT_RESOURCES" >>$autoregister_file; fi
if [ -n "$AGENT_ENVIRONMENTS" ]; then echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >>$autoregister_file; fi
chown go:go $autoregister_file

logfiles=(go-agent-bootstrapper.out.log go-agent-launcher.log go-agent-stderr.log go-agent-stdout.log go-agent.log)
(cd /var/log/go-agent; touch "${logfiles[@]}"; chown go:go "${logfiles[@]}"; tail -F -v "${logfiles[@]}" & disown)

exec /usr/share/go-agent/agent.sh
