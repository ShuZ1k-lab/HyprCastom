from evdev import InputDevice, categorize, ecodes, AbsInfo, list_devices

import uinput
import time

# Створюємо віртуальну мишку
events = (
    uinput.REL_X,
    uinput.REL_Y,
    uinput.BTN_LEFT,
)
device = uinput.Device(events)

# Знайти пристрій
devices = [InputDevice(path) for path in list_devices()]
for d in devices:
    print(d.path, d.name, d.phys)

dev = InputDevice('/dev/input/event19')

# Якщо потрібно, "grab" — щоб інші програми не отримували події
# dev.grab()

slot_positions = {}  # Для multitouch слоти
current_slot = 0

for event in dev.read_loop():
    if event.type == ecodes.EV_ABS:
        if event.code == ecodes.ABS_MT_SLOT:
            current_slot = event.value
            if current_slot not in slot_positions:
                slot_positions[current_slot] = {'x': 0, 'y': 0}
        elif event.code == ecodes.ABS_MT_POSITION_X:
            if current_slot not in slot_positions:
                slot_positions[current_slot] = {'x': 0, 'y': 0}
            slot_positions[current_slot]['x'] = event.value
        elif event.code == ecodes.ABS_MT_POSITION_Y:
            if current_slot not in slot_positions:
                slot_positions[current_slot] = {'x': 0, 'y': 0}
            slot_positions[current_slot]['y'] = event.value
        elif event.code == ecodes.ABS_MT_POSITION_X:
            slot_positions[current_slot]['x'] = event.value
        elif event.code == ecodes.ABS_MT_POSITION_Y:
            slot_positions[current_slot]['y'] = event.value
    elif event.type == ecodes.EV_SYN and event.code == ecodes.SYN_REPORT:
        
        for slot, pos in slot_positions.items():
            print(f"Slot {slot}: X={pos['x']} Y={pos['y']}")
            if pos['y'] > 900:
                device.emit(uinput.REL_Y, 2)
            if pos['y'] < 100:
                device.emit(uinput.REL_Y, -2)
            if pos['x'] > 1450:
                device.emit(uinput.REL_X, 2)
            if pos['x'] < 50:
                device.emit(uinput.REL_X, -2)