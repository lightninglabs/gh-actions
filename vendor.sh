#!/bin/bash
#
# Usage: ./vendor.sh [action-name...]
#
# Vendors the actions listed at the bottom of this file. With arguments, only
# the named actions are vendored.

set -euo pipefail

# Node image for actions that build with Yarn, pinned by digest.
NODE_IMAGE="node:24-alpine@sha256:a34ab6d7f6f4813f4d0c5469d74685604b962fbdbf5793a7bc7b4998ecb867c8"

SELECTED=("$@")

function download() {
  URL="https://github.com/$1/$2/archive/$3.tar.gz"
  echo "Downloading $URL"
  # Start clean so files removed upstream don't linger.
  rm -rf "@$2"
  mkdir -p "@$2/"
  curl -fsSL "$URL" | tar zx --strip-components=1 -C "@$2"
}

function build() {
  if [[ -f "@$1/yarn.lock" ]]; then
    # Install exactly what yarn.lock pins, in a container, as the current
    # user so the output isn't owned by root.
    docker run --rm \
      -u "$(id -u):$(id -g)" \
      -e HOME=/tmp \
      -e COREPACK_HOME=/tmp/corepack \
      -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
      -v "$PWD/@$1:/src" -w /src \
      "$NODE_IMAGE" \
      sh -c "corepack yarn install --immutable && corepack yarn run $2"
  else
    pushd "@$1"
    npm install
    npm run "$2"
    popd
  fi

  rm -rf "$1"
  mkdir -p "$1/dist"
  cp -r "@$1/dist/"* "$1/dist/"
  cp "@$1/action.yml" "$1/action.yml"
}

function vendor() {
  if [[ ${#SELECTED[@]} -gt 0 && ! " ${SELECTED[*]} " =~ " $2 " ]]; then
    return
  fi
  download "$1" "$2" "$3"
  build "$2" "$4"
}

vendor "softprops" "action-gh-release" "c062e08bd532815e2082a85e87e3ef29c3e6d191" "build"
vendor "docker" "login-action" "81c6f93d4bc991e510b342a00b419b3bb4efc5c6" "build"         # v4.7.0
vendor "docker" "build-push-action" "c3c9e263c25d99ce0380d002d59b67737d91b0dc" "build"    # v7.4.0
vendor "docker" "setup-buildx-action" "f87e5991a6d7451dcb8d9637bfbc97413f497069" "build"  # v4.4.1
vendor "docker" "setup-qemu-action" "99012661954931238ded8c8b007157a8430204e1" "build"    # v4.4.0
