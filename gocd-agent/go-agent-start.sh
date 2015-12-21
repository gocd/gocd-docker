#!/bin/bash

GO_SERVER=${GO_SERVER:-go-server}

COLOR_START="[01;34m"
COLOR_END="[00m"

echo -e "${COLOR_START}Starting Go Agent to connect to server $GO_SERVER ...${COLOR_END}"

echo "agent.auto.register.key=$AGENT_KEY" >/var/lib/go-agent/config/autoregister.properties

if [ -n "$AGENT_RESOURCES" ]; then echo "agent.auto.register.resources=$AGENT_RESOURCES" >>/var/lib/go-agent/config/autoregister.properties; fi
if [ -n "$AGENT_ENVIRONMENTS" ]; then echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >>/var/lib/go-agent/config/autoregister.properties; fi

exec /usr/share/go-agent/agent.sh
