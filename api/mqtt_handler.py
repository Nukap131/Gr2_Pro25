import json
import paho.mqtt.client as mqtt
import socket
from datetime import datetime

QUESTDB_ILP_HOST = "questdb"
QUESTDB_ILP_PORT = 9009

TOPIC = "ucl/ventilation"


def write_to_questdb(payload):

    # --- TIMESTAMP FIX ---
    ts = payload["timestamp"]
    if not ts.endswith("Z"):
        ts = ts + "Z"

    dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    epoch_ns = int(dt.timestamp() * 1_000_000_000)

    # --- ILP LINE (KORREKT TAG-SYNTAX: INGEN CITATIONER!) ---
    line = (
        f"maalinger,device={payload['device']} "
        f"udendoers_temp={payload['udendoers_temp']}f,"
        f"rum_temp={payload['rum_temp']}f,"
        f"tilluft_temp={payload['tilluft_temp']}f,"
        f"effektforbrug={payload['effektforbrug']}f,"
        f"virkningsgrad={payload['virkningsgrad']}f "
        f"{epoch_ns}"
    )

    print("ILP LINE SENT:", line, flush=True)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((QUESTDB_ILP_HOST, QUESTDB_ILP_PORT))
    sock.sendall(line.encode())
    sock.close()

    print("### SENT FIXED ILP TO QUESTDB ###", flush=True)


def on_message(client, userdata, msg):
    print("### RECEIVED MQTT MESSAGE ###", flush=True)
    data = json.loads(msg.payload.decode())
    write_to_questdb(data)


def start_mqtt_listener():
    print("### MQTT LISTENER STARTER ###", flush=True)
    client = mqtt.Client()
    client.on_message = on_message
    client.connect("mosquitto", 1883, 60)
    client.subscribe(TOPIC)
    client.loop_start()
