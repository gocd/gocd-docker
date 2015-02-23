#!/bin/bash

set -e

REPO=${REPO:-https://github.com/gocd/gocd.git}
COMMIT=${COMMIT:-master}

cd /home/gocd
git fetch "${REPO}" "${COMMIT}"
git reset --hard FETCH_HEAD

./bn clean cruise:prepare
