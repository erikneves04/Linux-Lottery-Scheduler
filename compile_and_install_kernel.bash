#!/bin/bash

# === Acesso ao diretório ===
cd 'linux-6.8'

# === CONFIG ===
KERNEL_NAME="kernel-ufmg"
THREADS=$(nproc)
BUILD_DIR=$(pwd)
LOGFILE="../build.log"

echo "[INFO] Iniciando build do kernel '$KERNEL_NAME' com $THREADS threads..."

# === 1. Preparar ambiente ===
echo "[INFO] Instalando dependências..."
sudo apt update
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc

# === 2. Configuração do kernel ===
echo "[INFO] Configurando kernel..."
make mrproper
make defconfig

# (Opcional: use menuconfig para personalizar)
# make menuconfig

# === 3. Adiciona sufixo custom para identificar no GRUB ===
scripts/config --set-str LOCALVERSION "-$KERNEL_NAME"

# === 4. Compilar ===
echo "[INFO] Compilando... (log em $LOGFILE)"
make -j"$THREADS" > "$LOGFILE" 2>&1
if [ $? -ne 0 ]; then
    echo "[ERRO] Falha na compilação. Veja $LOGFILE."
    exit 1
fi

# === 5. Instalar módulos e kernel ===
echo "[INFO] Instalando módulos..."
sudo make modules_install

echo "[INFO] Instalando kernel..."
sudo make install

# === 6. Atualizar GRUB ===
echo "[INFO] Atualizando GRUB..."
sudo update-initramfs -c -k $(make kernelrelease)
sudo update-grub

echo "[SUCESSO] Kernel instalado com sucesso!"
echo "→ Reinicie e selecione o kernel: $(make kernelrelease)"

# === 7. Verificação após reboot ===
echo -e "\n[INFO] Após o reboot, use: uname -r"
echo "Deve retornar: $(make kernelrelease)"
