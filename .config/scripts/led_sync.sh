#!/usr/bin/env bash

# Init Global Variable
DEVICE="/dev/snd/hwC0D0"
NID="0x01"
BIT_MIC="0x16"

# Control Mic Led
enable_mic_led() {
    sudo hda-verb "$DEVICE" "$NID" SET_GPIO_MASK "$BIT_MIC"
    sudo hda-verb "$DEVICE" "$NID" SET_GPIO_DIR "$BIT_MIC"
    sudo hda-verb "$DEVICE" "$NID" SET_GPIO_DATA 0x00
}

disable_mic_led() {
    sudo hda-verb "$DEVICE" "$NID" SET_GPIO_MASK "$BIT_MIC"
    sudo hda-verb "$DEVICE" "$NID" SET_GPIO_DIR "$BIT_MIC"
    sudo hda-verb "$DEVICE" "$NID" SET_GPIO_DATA "$BIT_MIC"
}

# Control Vol Led
enable_vol_led() {
    sudo hda-verb "$DEVICE" 0x20 0x500 0x0b
    sudo hda-verb "$DEVICE" 0x20 0x400 0x08
}

disable_vol_led() {
    sudo hda-verb "$DEVICE" 0x20 0x500 0x0b
    sudo hda-verb "$DEVICE" 0x20 0x400 0x00
}

# Main Cycle
flag_mic=""
flag_vol=""
while true; do
    # Check Status Mute
    mute_mic_state=$(pactl get-source-mute @DEFAULT_SOURCE@)
    mute_vol_state=$(pactl get-sink-mute @DEFAULT_SINK@)

    # If it has changed, we set a new level.
    if [[ "$mute_mic_state" != "$flag_mic" ]]; then
        flag_mic=$mute_mic_state
        if [[ "$mute_mic_state" == "Mute: yes" ]]; then
            enable_mic_led
        else
            disable_mic_led
        fi
    fi

    # If it has changed, we set a new level.
    if [[ "$mute_vol_state" != "$flag_vol" ]]; then
        flag_vol=$mute_vol_state
        if [[ "$mute_vol_state" == "Mute: yes" ]]; then
            enable_vol_led
        else
            disable_vol_led
        fi
    fi

    # Sleep for stabilize
    sleep 0.1
done
