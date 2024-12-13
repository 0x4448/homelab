FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

ENV SHELL /usr/bin/zsh

WORKDIR /

COPY setup.sh .
COPY requirements.txt .

RUN /setup.sh
