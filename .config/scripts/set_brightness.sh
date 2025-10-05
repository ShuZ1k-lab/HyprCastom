#!/usr/bin/env bash
# -----------------------------------------------------------
# Плавне регулювання яскравості через brightnessctl
# Не потребує sudo, працює від користувача
# Виклик: ./set_brightness_smooth_user.sh +10 або ./set_brightness_smooth_user.sh -5
# -----------------------------------------------------------

# Перевірка аргументу
if [ -z "$1" ]; then
    echo "Usage: $0 <+N|-N>  # приріст або зменшення яскравості у відсотках"
    exit 1
fi

# Локальна змінна приросту
change=$1

# Поточна яскравість у відсотках
current=$(brightnessctl g)
max=$(brightnessctl m)
current_percent=$(( current * 100 / max ))

# Цільова яскравість у відсотках
target_percent=$(( current_percent + change ))

# Обмеження 0–100%
if [ $target_percent -gt 100 ]; then
    target_percent=100
fi
if [ $target_percent -lt 5 ]; then
    target_percent=5
fi

# Локальна змінна для циклу
step=$current_percent

# Плавне збільшення
if [ $target_percent -gt $current_percent ]; then
    while [ $step -lt $target_percent ]; do
        step=$(( step + 1 ))
        # Встановлюємо яскравість через brightnessctl по відсотках
        brightnessctl s "$step"% > /dev/null
        sleep 0.01
    done
else
    # Плавне зменшення
    while [ $step -gt $target_percent ]; do
        step=$(( step - 1 ))
        brightnessctl s "$step"% > /dev/null
        sleep 0.01
    done
fi

echo "Brightness set to $target_percent%"

