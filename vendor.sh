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
vendor "docker" "login-action" "f3364599c6aa293cdc2b8391b1b56d0c30e45c8a" "build"
vendor "docker" "build-push-action" "4a531fa5a603bab87dfa56578bd82b28508c9547" "build"
vendor "docker" "setup-buildx-action" "154c24e1f33dbb5865a021c99f1318cfebf27b32" "build"
vendor "docker" "setup-qemu-action" "6520a2d2cb6db42c90c297c8025839c98e531268" "build"
