#!/bin/bash

# === Instalação dos requisitos ===
sudo apt update && sudo apt install -y \
  build-essential \
  libncurses-dev \
  bison \
  flex \
  libssl-dev \
  libelf-dev \
  libudev-dev \
  libpci-dev \
  libiberty-dev \
  dwarves \
  fakeroot \
  bc \
  wget \
  curl \
  git \
  grub-common \
  grub-pc-bin \
  linux-base \
  rsync
