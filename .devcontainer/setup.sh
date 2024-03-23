#!/usr/bin/env bash
set -eu

function download {
  filename="$1"
  url="$2"
  checksum="$3"

  curl --location --silent --show-error --output "$filename" "$url"
  echo "$checksum $filename" | sha256sum --check
  chmod +x "$filename"
  mv "$filename" /usr/local/bin
}

apt-get update
apt-get install --no-install-recommends --yes \
  shellcheck=0.9.0-1 \
  vim=2:9.0.1378-2
rm -rf /var/lib/apt/lists/*

download hadolint \
  https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
  56de6d5e5ec427e17b74fa48d51271c7fc0d61244bf5c90e828aab8362d55010

pip install --no-cache-dir --require-hashes -r requirements.txt
rm requirements.txt
rm setup.sh
