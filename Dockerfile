FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 
# ENV HTTPS_PROXY=http://host.docker.internal:7897 
# ENV HTTP_PROXY=http://host.docker.internal:7897 
# ENV ALL_PROXY=socks5://host.docker.internal:7897 

RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses-dev \
    bc \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    wget \
    xz-utils \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

CMD ["tail", "-f", "/dev/null"]
