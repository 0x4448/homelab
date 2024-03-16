FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

ENV SHELL /usr/bin/zsh

COPY download.sh /usr/local/bin/download

RUN apt-get update && apt-get install --no-install-recommends -y \
    vim=2:9.0.1378-2 \
    shellcheck=0.9.0-1 \
    && rm -rf /var/lib/apt/lists/* \
    && pipx install pre-commit==3.6.2 \
    && download hadolint \
        https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
        56de6d5e5ec427e17b74fa48d51271c7fc0d61244bf5c90e828aab8362d55010
