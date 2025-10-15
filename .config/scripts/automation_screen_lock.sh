

#!/usr/bin/env bash
# Скрипт автоматичного блокування та DPMS для Hyprland

swayidle \
    timeout 10 'swaylock -f -c 000000' \        # блокування через 5 хв
    timeout 20 'hyprctl dispatch dpms off' \     # вимикання екрана через 10 хв
    resume 'hyprctl dispatch dpms on' &           # при руху миші/тачпада включаємо екран
