#!/usr/bin/env bash
set -eu

branch="main"

while getopts ":b:h" opt; do
  case $opt in
    b)
      branch="$OPTARG"
      ;;
    h)
      echo "Usage: init.sh [OPTION]..."
      echo "Initialize a node."
      echo
      echo "  -b  git branch to use"
      echo "  -h  display this help and exit"
      exit 0
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      ;;
    ?)
      echo "init.sh: invalid option -$OPTARG"
      echo "Try 'init.sh -h' for more information."
      exit 1
      ;;
  esac
done


workDir=$(pwd)
repoDir=$(mktemp -d)

function cleanup {
  cd "$workDir"
  rm -rf "$repoDir"
}

trap cleanup EXIT

apt-get update
apt-get install --no-install-recommends --yes git pipx

export PIPX_HOME=/usr/local/pipx
export PIPX_BIN_DIR=/usr/local/bin
pipx install ansible-core

if [[ -z ${CI-} ]]; then
  cd "$repoDir" || exit 1
  git clone "https://github.com/0x4448/homelab" .
  git switch "$branch"
fi

ansible-playbook --become playbook.yml
