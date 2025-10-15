#!/usr/bin/env bash
# -----------------------------------------------------------
# Скрипт установки для led_sync.sh
# -----------------------------------------------------------

# 0️⃣ Отримуємо директорію, де лежить цей install.sh
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$INSTALL_DIR")"

# 1️⃣ Встановлюємо alsa-tools через pacman
echo "Installing alsa-tools..."
sudo pacman -S --noconfirm alsa-tools

# 2️⃣ Створюємо папку для скриптів у .config
CONFIG_DIR="$HOME/.config/scripts"
echo "Creating folder $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

# 3️⃣ Копіюємо скрипт у папку
# Тепер шлях обчислюється відносно самого install.sh
SRC_SCRIPT="$SCRIPT_DIR/scripts/led_sync.sh"
DEST_SCRIPT="$CONFIG_DIR/led_sync.sh"

if [ ! -f "$SRC_SCRIPT" ]; then
    echo "Error: $SRC_SCRIPT not found!"
    exit 1
fi

echo "Copying $SRC_SCRIPT to $DEST_SCRIPT..."
cp "$SRC_SCRIPT" "$DEST_SCRIPT"

# 4️⃣ Додаємо права на виконання
echo "Making script executable..."
chmod +x "$DEST_SCRIPT"

# 5️⃣ Інформаційне повідомлення
echo "Installation complete!\n"