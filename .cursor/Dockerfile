FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        g++ \
        git \
        jq \
        libayatana-appindicator3-dev \
        libgtk-3-dev \
        librsvg2-dev \
        libssl-dev \
        libstdc++-14-dev \
        libwebkit2gtk-4.1-dev \
        pkg-config \
        python3 \
        sudo \
        unzip \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

# Hermit and the repo checkout expect a normal non-root user.
RUN useradd -m -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu
WORKDIR /home/ubuntu
