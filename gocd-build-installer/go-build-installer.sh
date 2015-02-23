#!/bin/bash

set -e

function help_and_exit {
  local usage_prefix="docker run -it -v \`pwd\`/installers:/installers gocd-build-installer"

  cat <<EOF
[01;31mError: $1[00m

[01;34mUsage: $usage_prefix installer-name [installer-name...][00m
  where each installer-name can be one of:
    win or windows
    osx or mac
    deb or debian
    rpm or redhat or centos
    zip

Example: $usage_prefix deb osx
  to build the Debian and Mac OS X installers.

Options (environment variables):
  REPO   - To configure which git repository should be used. Defaults to https://github.com/gocd/gocd.git.
  COMMIT - To configure which commit to use in that repository. Defaults to master.

Example: $usage_prefix -e REPO=https://github.com/arvindsv/gocd.git -e COMMIT=my_new_feature deb
  to build the Debian installers for my_new_feature branch on the repository mentioned above.
EOF

  exit 1
}

# Parse arguments.
declare -a INSTALLERS_NEEDED
while [ "$#" -ge 1 ]; do
  case "$1" in
    win|windows)
      INSTALLERS_NEEDED+=(cruise:pkg:windows)
      ;;
    osx|mac)
      INSTALLERS_NEEDED+=(cruise:pkg:osx)
      ;;
    rpm|redhat|centos)
      INSTALLERS_NEEDED+=(cruise:pkg:redhat)
      ;;
    deb|debian)
      INSTALLERS_NEEDED+=(cruise:pkg:debian)
      ;;
    zip)
      INSTALLERS_NEEDED+=(cruise:pkg:zip)
      ;;
    *)
      help_and_exit "Invalid installer name: $1"
      ;;
  esac

  shift
done

if [ "$(echo "${INSTALLERS_NEEDED[@]}" | grep -q '^$'; echo $?)" = "0" ]; then
  help_and_exit "No installers requested"
fi


export WINDOWS_JRE_LOCATION='https://download.go.cd/local/jre-7u9-windows-i586.tar.gz'
export DISABLE_WIN_INSTALLER_LOGGING='true'
export REPO # Used by go-compile.sh
export COMMIT # Used by go-compile.sh

# To handle a bug, when redhat has to be specified before debian. Otherwise it fails. :(
INSTALLERS_NEEDED=($(echo "${INSTALLERS_NEEDED[@]}" | tr -s ' ' '\n' | sort -r))
echo -e "[01;34mRunning for installer targets: ${INSTALLERS_NEEDED[@]}[00m"

cd /home/gocd
$(dirname $0)/go-compile.sh
tools/bin/go.jruby -J-Xmx2048m -J-Xms1024m -S buildr ${INSTALLERS_NEEDED[@]} ratchet=no test=no DO_NOT_INSTRUMENT_FOR_COVERAGE=true --trace

mkdir -p /installers
cp -vaR /home/gocd/target/pkg/* /installers/
rm -f /installers/install-server.sh
