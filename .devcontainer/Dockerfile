FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

ENV SHELL /usr/bin/zsh

RUN apt update && apt install -y \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN pipx install pre-commit
