#!/usr/bin/env bash
set -eu

function download {
  local OPTIND
  local tarArgs

  # Parse optional arguments.
  while getopts ":Jjz" opt; do
    case $opt in
      J|j|z)
        tarArgs="x${opt}f"
        ;;
      ?)
        echo "Usage: download [OPTION]... [BINARYNAME] [URL] [CHECKSUM]"
        exit 1
        ;;
    esac
  done

  shift $((OPTIND - 1))

  # Parse positional arguments
  binaryName="$1"
  url="$2"
  checksum="$3"

  # Download to temp directory
  workDir=$(pwd)
  tempDir=$(mktemp -d)
  fileName=$(basename "$url")
  cd "$tempDir" || exit 1

  curl \
    --connect-timeout 10 \
    --retry 5 \
    --max-time 120 \
    --location --silent --show-error \
    --output "$fileName" "$url"

  echo "$checksum $fileName" | sha256sum --check

  if [[ -n ${tarArgs-} ]]; then
    tar "$tarArgs" "$fileName"
  else
    mv "$fileName" "$binaryName"
  fi

  chmod +x "$binaryName"
  mv "$binaryName" /usr/local/bin

  cd "$workDir" || exit 1
  rm -rf "$tempDir"
}

wget -O- https://apt.releases.hashicorp.com/gpg |
  gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
  tee /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install --no-install-recommends --yes \
  terraform=1.9.8-1 \
  shellcheck=0.9.0-1 \
  vim=2:9.0.1378-2
rm -rf /var/lib/apt/lists/*

download -z actionlint \
  https://github.com/rhysd/actionlint/releases/download/v1.6.27/actionlint_1.6.27_linux_amd64.tar.gz \
  5c9b6e5418f688b7f7c7e3d40c13d9e41b1ca45fb6a2c35788b0580e34b7300f

download hadolint \
  https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
  56de6d5e5ec427e17b74fa48d51271c7fc0d61244bf5c90e828aab8362d55010

pip install --no-cache-dir --require-hashes -r requirements.txt
rm requirements.txt
rm setup.sh
