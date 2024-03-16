FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

ENV SHELL /usr/bin/zsh

COPY download.sh /usr/local/bin/download

RUN apt update && apt install -y \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN pipx install pre-commit

RUN download hadolint \
    https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
    56de6d5e5ec427e17b74fa48d51271c7fc0d61244bf5c90e828aab8362d55010
