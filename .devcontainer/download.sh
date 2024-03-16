#!/usr/bin/env bash
set -eu

filename="$1"
url="$2"
checksum="$3"

curl --location --silent --show-error --output "$filename" "$url"
echo "$checksum $filename" | sha256sum --check
chmod +x "$filename"
mv "$filename" /usr/local/bin
