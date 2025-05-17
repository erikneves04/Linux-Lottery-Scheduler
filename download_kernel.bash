#!/bin/bash

# === CONFIGURAÇÕES ===
KERNEL_VERSION="6.8"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
DEST_DIR= "." #"$HOME/kernel-dev"
ARCHIVE_NAME="linux-${KERNEL_VERSION}.tar.xz"
SRC_DIR="linux-${KERNEL_VERSION}"

# === CRIAR DIRETÓRIO DESTINO ===
mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit 1

# === FAZER DOWNLOAD ===
echo "[INFO] Baixando o kernel $KERNEL_VERSION..."
if [ -f "$ARCHIVE_NAME" ]; then
    echo "[INFO] Arquivo já existe, pulando download."
else
    wget "$KERNEL_URL" -O "$ARCHIVE_NAME"
    if [ $? -ne 0 ]; then
        echo "[ERRO] Falha no download."
        exit 1
    fi
fi

# === EXTRAIR ===
if [ -d "$SRC_DIR" ]; then
    echo "[INFO] Diretório '$SRC_DIR' já existe, pulando extração."
else
    echo "[INFO] Extraindo o kernel..."
    tar -xf "$ARCHIVE_NAME"
fi

echo "[SUCESSO] Kernel $KERNEL_VERSION baixado e extraído em $DEST_DIR/$SRC_DIR"
