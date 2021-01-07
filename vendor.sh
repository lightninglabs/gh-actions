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
vendor "aws-actions" "configure-aws-credentials" "e97d7fbc8e0e5af69631c13daa0f4b5a8d88165b" "package"
vendor "aws-actions" "amazon-ecr-login" "b9c809dc38d74cd0fde3c13cc4fe4ac72ebecdae" "package"
