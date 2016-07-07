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

MANUAL_SETTING=${MANUAL_SETTING:-"N"}

if [ "$MANUAL_SETTING" == "N" ]; then
    if [ -f /config/default/go-server ]; then
        echo "[$(date)] using default settings from /config/default/go-server"
        . /config/default/go-server
    fi
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

[ ! -z $SERVER_MEM ] || SERVER_MEM="512m"
[ ! -z $SERVER_MAX_MEM ] || SERVER_MAX_MEM="1024m"
[ ! -z $SERVER_MAX_PERM_GEN ] || SERVER_MAX_PERM_GEN="256m"
[ ! -z $SERVER_MIN_PERM_GEN ] || SERVER_MIN_PERM_GEN="128m"
[ ! -z $GO_SERVER_PORT ] || GO_SERVER_PORT="8153"
[ ! -z $GO_SERVER_SSL_PORT ] || GO_SERVER_SSL_PORT="8154"
[ ! -z "$SERVER_WORK_DIR" ] || SERVER_WORK_DIR="/var/lib/go-server"
[ ! -z "$YOURKIT_DISABLE_TRACING" ] || YOURKIT_DISABLE_TRACING=""

if [ -d /logs ]; then
    STDOUT_LOG_FILE=/logs/go-server.out.log
else
    STDOUT_LOG_FILE=go-server.out.log
fi

if [ -d /var/run/go-server ]; then
    PID_FILE=/var/run/go-server/go-server.pid
else
    PID_FILE=go-server.pid
fi

GO_CONFIG_DIR=/var/lib/go-server/config

if [ "$JVM_DEBUG" != "" ]; then
    JVM_DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
else
    JVM_DEBUG=''
fi

if [ "$GC_LOG" != "" ]; then
    GC_LOG="-verbose:gc -Xloggc:go-server-gc.log -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+PrintGCDetails -XX:+PrintGC"
else
    GC_LOG=''
fi

if [ ! -z $SERVER_LISTEN_HOST ]; then
    GO_SERVER_SYSTEM_PROPERTIES+="-Dcruise.listen.host=$SERVER_LISTEN_HOST"
fi


# Bootstrapping
if [ ! -f /config/gocd-server-config.xml ]; then
  echo "Bootstrapping initial configuration."
  unzip -qq /go-server/go.jar defaultFiles/config/cruise-config.xml
  cp defaultFiles/config/cruise-config.xml /config/gocd-server-config.xml
fi
AGENT_KEY="${AGENT_KEY:-123456789abcdef}"
[[ -n "$AGENT_KEY" ]] && sed -i -e 's/agentAutoRegisterKey="[^"]*" *//' -e 's#\(<server\)\(.*artifactsdir.*\)#\1 agentAutoRegisterKey="'$AGENT_KEY'"\2#' /config/gocd-server-config.xml
if [ ! -d /config/db ]; then
  echo "Bootstrapping database."
  mkdir /config/db
  unzip -qq /go-server/go.jar defaultFiles/h2db.zip
  unzip -qq defaultFiles/h2db.zip -d /config/db
fi

echo "Preparing database migrations."
unzip -qq /go-server/go.jar defaultFiles/h2deltas.zip
unzip -qq defaultFiles/h2deltas.zip -d /config/db

rm -rf defaultFiles

[[ ! -d /config/addons ]] && mkdir /config/addons
[[ ! -d /config/plugins ]] && mkdir /config/plugins
[[ ! -d /config/default ]] && mkdir -p /config/default
[[ ! -d /config/etc ]] && mkdir -p /config/etc

SERVER_STARTUP_ARGS="-server -Djava.security.egd=file:/dev/./urandom -XX:HeapDumpPath=/logs -XX:ErrorFile=/logs/jvm-error.log"
SERVER_STARTUP_ARGS="${SERVER_STARTUP_ARGS} -Xms$SERVER_MEM -Xmx$SERVER_MAX_MEM -XX:PermSize=$SERVER_MIN_PERM_GEN -XX:MaxPermSize=$SERVER_MAX_PERM_GEN"
SERVER_STARTUP_ARGS="${SERVER_STARTUP_ARGS} ${JVM_DEBUG} ${GC_LOG} ${GO_SERVER_SYSTEM_PROPERTIES}"
SERVER_STARTUP_ARGS="${SERVER_STARTUP_ARGS} -Duser.language=en -Djruby.rack.request.size.threshold.bytes=30000000"
SERVER_STARTUP_ARGS="${SERVER_STARTUP_ARGS} -Duser.country=US -Dcruise.config.dir=$GO_CONFIG_DIR -Dcruise.config.file=$GO_CONFIG_DIR/gocd-server-config.xml"
SERVER_STARTUP_ARGS="${SERVER_STARTUP_ARGS} -Dcruise.server.port=$GO_SERVER_PORT -Dcruise.server.ssl.port=$GO_SERVER_SSL_PORT"

echo Starting GoCD server with command: $(autoDetectJavaExecutable) -jar /go-server/go.jar ${SERVER_STARTUP_ARGS}
echo Starting GoCD server in directory: $SERVER_WORK_DIR
cd "$SERVER_WORK_DIR"
exec $(autoDetectJavaExecutable) -jar /go-server/go.jar ${SERVER_STARTUP_ARGS}
