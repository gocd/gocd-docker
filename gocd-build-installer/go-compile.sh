#!/bin/bash

set -e

REPO=${REPO:-https://github.com/gocd/gocd.git}
BRANCH=${BRANCH:-master}

cd /home/gocd
git fetch "${REPO}" "${BRANCH}"
git reset --hard FETCH_HEAD

./bn clean cruise:prepare
