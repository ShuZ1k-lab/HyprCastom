#!/usr/bin/env bash
# -----------------------------------------------------------
# Скрипт установки для set_brightness.sh
# -----------------------------------------------------------

# 1️⃣ Встановлюємо brightnessctl через pacman
echo "Installing brightnessctl..."
sudo pacman -S --noconfirm brightnessctl

# 2️⃣ Створюємо папку для скриптів у .config
CONFIG_DIR="$HOME/.config/scripts"
echo "Creating folder $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

# 3️⃣ Копіюємо скрипт у папку
# Вважаємо, що install.sh знаходиться в корені проекту, а скрипт у ./scripts/
SRC_SCRIPT="../scripts/set_brightness.sh"
DEST_SCRIPT="$CONFIG_DIR/set_brightness.sh"

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
echo "Installation complete!"
echo "You can now run the script via: $DEST_SCRIPT +10"
