#!/bin/bash

. go-common-scripts.sh

exec > >(sed -e 's/.*/AGNT: &/') 2>&1
[[ -n "$AGENT_LOGS_DISABLE" ]] && exec >/dev/null 2>&1

wait_for_go_server
wait_for_msg_time "" # To prevent agent log messages from obscuring the message that the server wants to show.
show_msg "Starting Go Agent ..."

/sbin/setuser go /etc/init.d/go-agent start
