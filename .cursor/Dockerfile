FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        file \
        g++ \
        git \
        jq \
        libayatana-appindicator3-dev \
        libgtk-3-dev \
        librsvg2-dev \
        libsoup-3.0-dev \
        libssl-dev \
        libstdc++-14-dev \
        libwebkit2gtk-4.1-dev \
        pkg-config \
        python3 \
        sudo \
        unzip \
        xz-utils \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

# ubuntu:24.04 already ships uid 1000 named ubuntu. `useradd ubuntu` fails the
# Cloud Agent image build with: useradd: user 'ubuntu' already exists.
RUN if ! id -u ubuntu >/dev/null 2>&1; then \
      useradd -m -s /bin/bash ubuntu; \
    fi \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu
