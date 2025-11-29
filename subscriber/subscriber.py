import json
import time
import random
import math
import socket
import logging
from logging.handlers import RotatingFileHandler
from datetime import datetime
import paho.mqtt.client as mqtt

# ==========================================================
#  LOGGING
# ==========================================================
log = logging.getLogger("subscriber")
log.setLevel(logging.INFO)

# Filhandler
fh = logging.FileHandler("/var/log/subscriber/subscriber.log")
fh.setLevel(logging.INFO)

# Terminalhandler
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)

# Format
fmt = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
fh.setFormatter(fmt)
ch.setFormatter(fmt)

log.addHandler(fh)
log.addHandler(ch)

log.info("Subscriber starter ...")


# ==========================================================
#  KONSTANTER
# ==========================================================
TOPIC = "ucl/ventilation"
DEVICE = "Ventilationsanlaeg"

QUESTDB_ILP_HOST = "questdb"
QUESTDB_ILP_PORT = 9009

client = mqtt.Client()
client.connect("mosquitto", 1883, 60)

log.info("MQTT forbindelse oprettet til mosquitto:1883")


# ==========================================================
#  MODELLER (SIMULATION)
# ==========================================================
def udendoers_temp(t):
    base = 6 + 2 * math.sin(t / 2000)
    noise = random.uniform(-0.2, 0.2)
    return round(base + noise, 2)

def rum_temp(t):
    base = 21 + 0.3 * math.sin(t / 1500)
    people_effect = random.uniform(-0.1, 0.15)
    noise = random.uniform(-0.05, 0.05)
    return round(base + people_effect + noise, 2)

def tilluft_temp(t, ute, rum):
    base = ute + (rum - ute) * 0.35
    noise = random.uniform(-0.15, 0.15)
    return round(base + noise, 2)

def effektforbrug(t, rum, ute):
    delta = abs(rum - ute)
    base = 140 + delta * 4
    motor_variation = random.uniform(-3, 3)
    return round(base + motor_variation, 2)

def virkningsgrad(t, eff):
    base = 78 - (eff - 150) * 0.03
    noise = random.uniform(-0.2, 0.2)
    return round(base + noise, 2)


# ==========================================================
#  ILP → QUESTDB
# ==========================================================
def write_to_questdb(payload):
    ts = payload["timestamp"]
    if not ts.endswith("Z"):
        ts = ts + "Z"

    dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    epoch_ns = int(dt.timestamp() * 1_000_000_000)

    line = (
        f"maalinger,device={payload['device']} "
        f"udendoers_temp={payload['udendoers_temp']},"
        f"rum_temp={payload['rum_temp']},"
        f"tilluft_temp={payload['tilluft_temp']},"
        f"effektforbrug={payload['effektforbrug']},"
        f"virkningsgrad={payload['virkningsgrad']} "
        f"{epoch_ns}\n"
    )

    log.info(f"Sender ILP til QuestDB: {line.strip()}")

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((QUESTDB_ILP_HOST, QUESTDB_ILP_PORT))
    sock.sendall(line.encode())
    sock.close()


# ==========================================================
#  MAIN LOOP
# ==========================================================
log.info("Realistisk simulation starter...")

while True:
    now = time.time()

    ute = udendoers_temp(now)
    rum = rum_temp(now)
    tluft = tilluft_temp(now, ute, rum)
    eff = effektforbrug(now, rum, ute)
    virk = virkningsgrad(now, eff)

    payload = {
        "device": DEVICE,
        "timestamp": datetime.utcnow().isoformat(),
        "udendoers_temp": ute,
        "rum_temp": rum,
        "tilluft_temp": tluft,
        "effektforbrug": eff,
        "virkningsgrad": virk
    }

    log.info(f"Publish MQTT: {payload}")

    client.publish(TOPIC, json.dumps(payload))
    write_to_questdb(payload)

    time.sleep(60)
