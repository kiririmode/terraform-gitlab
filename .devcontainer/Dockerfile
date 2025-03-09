FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

ARG TERRAFORM_VERSION=1.9.6

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install -y --no-install-recommends \
    direnv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget -qO /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-arm64 \
    && chmod +x /bin/hadolint 

# install AWSCLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws
