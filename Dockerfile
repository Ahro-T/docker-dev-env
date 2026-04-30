FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    git curl ca-certificates tmux \
    build-essential pkg-config libssl-dev \
    cargo rustc \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
