#!/usr/bin/env python3
"""
Simulează un ESP32 cu senzori de irigație.
Publică valori realiste pe MQTT la fiecare INTERVAL secunde.
"""

import time
import random
import paho.mqtt.client as mqtt

# --- Configurare ---
BROKER   = "broker.hivemq.com"
PORT     = 1883
CLIENT_ID = "esp32_simulator"
INTERVAL = 5   # secunde între citiri

# Topicuri (trebuie să coincidă cu cele din aplicație)
T_SOIL    = "smart_irrigation/sensors/soil_moisture"
T_TEMP    = "smart_irrigation/sensors/temperature"
T_HUM     = "smart_irrigation/sensors/humidity"
T_WATER   = "smart_irrigation/sensors/water_level"
T_PUMP    = "smart_irrigation/pump/status"
T_MODE    = "smart_irrigation/control_mode"

# Stare simulată (evoluează în timp, nu e pur random)
state = {
    "soil":  55.0,
    "temp":  22.0,
    "hum":   60.0,
    "water": 75.0,
    "pump":  False,
}

def drift(value, low, high, step):
    """Mică variație față de valoarea precedentă."""
    value += random.uniform(-step, step)
    return round(max(low, min(high, value)), 1)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f"[OK] Conectat la {BROKER}:{PORT}")
        # Ascultă comenzile de pompă venite din aplicație
        client.subscribe("smart_irrigation/pump/control")
        client.subscribe("smart_irrigation/control_mode")
    else:
        print(f"[ERR] Conexiune eșuată, cod {rc}")

def on_message(client, userdata, msg):
    payload = msg.payload.decode()
    if msg.topic == "smart_irrigation/pump/control":
        state["pump"] = (payload.upper() == "ON")
        print(f"  -> Comandă pompă: {payload}")
    elif msg.topic == "smart_irrigation/control_mode":
        print(f"  -> Mod control: {payload}")

def publish_sensors(client):
    state["soil"]  = drift(state["soil"],  10, 95, 2.0)
    state["temp"]  = drift(state["temp"],  15, 40, 0.5)
    state["hum"]   = drift(state["hum"],   30, 95, 1.5)
    state["water"] = drift(state["water"],  5, 100, 0.8)

    # Dacă pompa e pornită, umiditatea solului crește mai repede
    if state["pump"]:
        state["soil"] = min(95, state["soil"] + random.uniform(1, 3))

    pump_str = "ON" if state["pump"] else "OFF"

    client.publish(T_SOIL,  str(state["soil"]))
    client.publish(T_TEMP,  str(state["temp"]))
    client.publish(T_HUM,   str(state["hum"]))
    client.publish(T_WATER, str(state["water"]))
    client.publish(T_PUMP,  pump_str)

    print(
        f"Soil: {state['soil']}%  Temp: {state['temp']}°C  "
        f"Hum: {state['hum']}%  Water: {state['water']}%  Pump: {pump_str}"
    )

def main():
    client = mqtt.Client(client_id=CLIENT_ID)
    client.on_connect = on_connect
    client.on_message = on_message

    print(f"Conectare la {BROKER}:{PORT} ...")
    client.connect(BROKER, PORT, keepalive=60)
    client.loop_start()

    # Publică modul initial
    time.sleep(1)
    client.publish(T_MODE, "MANUAL")

    try:
        while True:
            publish_sensors(client)
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        print("\nOprit.")
    finally:
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
