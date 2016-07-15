#!/bin/sh
##########################################################################
# Copyright 2016 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

GO_SERVER=${GO_SERVER:-go-server}
AGENT_DIR='/go-agent'

mkdir -p /etc/default
sed -i -e 's/GO_SERVER=.*/GO_SERVER='$GO_SERVER'/' /etc/default/go-agent

mkdir -p ${AGENT_DIR}/config
/bin/rm -f ${AGENT_DIR}/config/autoregister.properties

AGENT_KEY="${AGENT_KEY:-123456789abcdef}"``
echo "agent.auto.register.key=$AGENT_KEY" >${AGENT_DIR}/config/autoregister.properties
if [ -n "$AGENT_RESOURCES" ]; then echo "agent.auto.register.resources=$AGENT_RESOURCES" >>${AGENT_DIR}/config/autoregister.properties; fi
if [ -n "$AGENT_ENVIRONMENTS" ]; then echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >>${AGENT_DIR}/config/autoregister.properties; fi

if [ -f /etc/default/go-agent ]; then
    echo "[$(date)] using default settings from /etc/default/go-agent"
    . /etc/default/go-agent
fi

yell() {
  echo "$*" >&2;
}

die() {
    yell "$1"
    exit ${2:-1}
}

autoDetectJavaExecutable() {
  local java_cmd
  # Prefer using GO_JAVA_HOME, over JAVA_HOME
  GO_JAVA_HOME=${GO_JAVA_HOME:-"$JAVA_HOME"}

  if [ -n "$GO_JAVA_HOME" ] ; then
      if [ -x "$GO_JAVA_HOME/jre/sh/java" ] ; then
          # IBM's JDK on AIX uses strange locations for the executables
          java_cmd="$GO_JAVA_HOME/jre/sh/java"
      else
          java_cmd="$GO_JAVA_HOME/bin/java"
      fi
      if [ ! -x "$java_cmd" ] ; then
          die "ERROR: GO_JAVA_HOME is set to an invalid directory: $GO_JAVA_HOME

Please set the GO_JAVA_HOME variable in your environment to match the
location of your Java installation."
      fi
  else
      java_cmd="java"
      which java >/dev/null 2>&1 || die "ERROR: GO_JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the GO_JAVA_HOME variable in your environment to match the
location of your Java installation."
  fi

  echo "$java_cmd"
}


AGENT_MEM=${AGENT_MEM:-"128m"}
AGENT_MAX_MEM=${AGENT_MAX_MEM:-"256m"}
GO_SERVER=${GO_SERVER:-"127.0.0.1"}
GO_SERVER_PORT=${GO_SERVER_PORT:-"8153"}
JVM_DEBUG_PORT=${JVM_DEBUG_PORT:-"5006"}
VNC=${VNC:-"N"}


AGENT_WORK_DIR=$AGENT_DIR
if [ ! -d "${AGENT_WORK_DIR}" ]; then
    echo Agent working directory ${AGENT_WORK_DIR} does not exist
    exit 2
fi

LOG_DIR=/logs
STDOUT_LOG_FILE=$LOG_DIR/bootstrapper.out.log
PID_FILE=/var/run/go-agent/go-agent.pid

if [ "$VNC" == "Y" ]; then
    echo "[$(date)] Starting up VNC on :3"
    /usr/bin/vncserver :3
    DISPLAY=:3
    export DISPLAY
fi

if [ "$JVM_DEBUG" != "" ]; then
    JVM_DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=${JVM_DEBUG_PORT}"
else
    JVM_DEBUG=""
fi

if [ "$GC_LOG" != "" ]; then
    GC_LOG="-verbose:gc -Xloggc:${SERVICE_NAME}-gc.log -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+PrintGCDetails -XX:+PrintGC"
else
    GC_LOG=""
fi

AGENT_STARTUP_ARGS="-Dcruise.console.publish.interval=10 -Xms$AGENT_MEM -Xmx$AGENT_MAX_MEM $JVM_DEBUG $GC_LOG $GO_AGENT_SYSTEM_PROPERTIES"
if [ "$TMPDIR" != "" ]; then
    AGENT_STARTUP_ARGS="$AGENT_STARTUP_ARGS -Djava.io.tmpdir=$TMPDIR"
fi
if [ "$USE_URANDOM" != "false" ] && [ -e "/dev/urandom" ]; then
    AGENT_STARTUP_ARGS="$AGENT_STARTUP_ARGS -Djava.security.egd=file:/dev/./urandom"
fi
export AGENT_STARTUP_ARGS
export LOG_DIR
export LOG_FILE

echo_or_exec_go() {
  sh_command=${1-'exec'}
  gocd_command="$(autoDetectJavaExecutable) -XX:HeapDumpPath=/logs -XX:ErrorFile=/logs/jvm-error.log ${AGENT_STARTUP_ARGS} -jar $AGENT_DIR/agent-bootstrapper.jar $GO_SERVER $GO_SERVER_PORT"
  export -p LANG="UTF-8"
  eval "${sh_command} ${gocd_command}"
}

echo_or_exec_go "echo [$(date)] Starting Go Agent Bootstrapper with command:"
echo "[$(date)] Starting Go Agent Bootstrapper in directory: $AGENT_WORK_DIR"
cd "$AGENT_WORK_DIR"

echo_or_exec_go
