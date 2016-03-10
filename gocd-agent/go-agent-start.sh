#!/bin/bash

GO_SERVER=${GO_SERVER:-go-server}
AGENT_KEY=${AGENT_KEY:-123456789abcdef}
DAEMON=${DAEMON:-N}

COLOR_START="[01;34m"
COLOR_END="[00m"

mkdir -p /var/lib/go-agent/config /var/run/go-agent /var/log/go-agent
chown -R go:go /var/lib/go-agent/config /var/run/go-agent /var/log/go-agent

autoregister_file=/var/lib/go-agent/config/autoregister.properties
logfiles=(go-agent-bootstrapper.out.log go-agent-launcher.log go-agent-stderr.log go-agent-stdout.log go-agent.log)

echo -e "${COLOR_START}Starting Go Agent to connect to server $GO_SERVER ...${COLOR_END}"
sed -i \
    -e 's/GO_SERVER=.*/GO_SERVER='$GO_SERVER'/' \
    -e 's/DAEMON=.*/DAEMON='$DAEMON'/' \
    /etc/default/go-agent

echo "agent.auto.register.key=$AGENT_KEY" >$autoregister_file
if [ -n "$AGENT_RESOURCES" ]; then echo "agent.auto.register.resources=$AGENT_RESOURCES" >>$autoregister_file; fi
if [ -n "$AGENT_ENVIRONMENTS" ]; then echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >>$autoregister_file; fi
chown go:go $autoregister_file

(cd /var/log/go-agent; touch "${logfiles[@]}"; chown go:go "${logfiles[@]}"; tail -F -v "${logfiles[@]}" & disown)
exec sudo -u go -i /usr/share/go-agent/agent.sh
