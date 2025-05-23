#!/bin/bash

# === CONFIGURAÇÕES ===
KERNEL_NAME="kernel-ufmg"
KERNEL_DIR="linux-6.8"
THREADS=$(nproc)
LOGFILE="../build.log"
USE_CCACHE=true  # Defina como false para desativar ccache

# === ENTRAR NO DIRETÓRIO DO KERNEL ===
cd "$KERNEL_DIR" || { echo "[ERRO] Diretório $KERNEL_DIR não encontrado!"; exit 1; }

echo "[INFO] Iniciando build do kernel '$KERNEL_NAME' com $THREADS threads..."
echo "[INFO] Log: $LOGFILE"

# === DEPENDÊNCIAS ===
echo "[INFO] Instalando dependências..."
sudo apt update
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc ccache

# === CONFIGURANDO AMBIENTE ===
if [ "$USE_CCACHE" = true ]; then
  echo "[INFO] Ativando ccache..."
  export CC="ccache gcc"
  export CXX="ccache g++"
fi

# === CONFIGURAÇÃO DO KERNEL ===
echo "[INFO] Carregando configuração existente..."
make olddefconfig

# === OPCIONAL: menuconfig para ajustes manuais ===
# echo "[INFO] Abrindo menuconfig (opcional)..."
# make menuconfig

# === DEFINIR SUFIXO CUSTOM ===
echo "[INFO] Adicionando sufixo -$KERNEL_NAME ao kernel..."
scripts/config --set-str LOCALVERSION "-$KERNEL_NAME"

# === COMPILAÇÃO ===
echo "[INFO] Compilando kernel... Isso pode levar vários minutos."
make -j"$THREADS" > "$LOGFILE" 2>&1

if [ $? -ne 0 ]; then
  echo "[ERRO] Falha na compilação. Veja o log em $LOGFILE"
  exit 1
fi

# === INSTALAÇÃO ===
echo "[INFO] Instalando módulos..."
sudo make modules_install

echo "[INFO] Instalando kernel..."
sudo make install

# === ATUALIZAR INITRAMFS E GRUB ===
KERNEL_VERSION=$(make kernelrelease)
echo "[INFO] Atualizando initramfs e grub para $KERNEL_VERSION..."
sudo update-initramfs -c -k "$KERNEL_VERSION"
sudo update-grub

echo -e "\n[INFO] Após o reboot, verifique com:"
echo "→ uname -r (deve mostrar: $KERNEL_VERSION)"
echo "→ sudo dmesg | grep DEBUG (para ver suas mensagens customizadas)"

# === CONCLUSÃO E REBOOT ===
echo -e "\n[SUCESSO] Kernel $KERNEL_VERSION instalado com sucesso!"
echo "→ O sistema será reiniciado automaticamente em 10 segundos..."
echo "→ Pressione Ctrl+C para cancelar o reboot."
sleep 10
sudo reboot
