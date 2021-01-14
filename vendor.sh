#!/bin/bash

set +x

function download() {
  URL="https://github.com/$1/$2/archive/$3.tar.gz"
  echo "Downloading $URL"
  mkdir -p "@$2/"
  curl -L "$URL" | tar zxv --strip-components=1 -C "@$2"
}

function build() {
  pushd "@$1"
  npm install
  npm run "$2"
  popd

  mkdir -p "$1/dist"
  cp -r "@$1/dist/"* "$1/dist/"
  cp "@$1/action.yml" "$1/action.yml"
}

function vendor() {
  download "$1" "$2" "$3"
  build "$2" "$4"
}

vendor "softprops" "action-gh-release" "91409e712cf565ce9eff10c87a8d1b11b81757ae" "build"
vendor "docker" "login-action" "f3364599c6aa293cdc2b8391b1b56d0c30e45c8a" "build"
vendor "docker" "build-push-action" "4a531fa5a603bab87dfa56578bd82b28508c9547" "build"
vendor "docker" "setup-buildx-action" "154c24e1f33dbb5865a021c99f1318cfebf27b32" "build"
vendor "docker" "setup-qemu-action" "6520a2d2cb6db42c90c297c8025839c98e531268" "build"
