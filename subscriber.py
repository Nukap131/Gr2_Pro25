import paho.mqtt.client as mqtt
import json
import sqlite3
import datetime

DB_PATH = "/home/victor/tempprojekt/sensordata.db"

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode())

        conn = sqlite3.connect(DB_PATH)
        cur = conn.cursor()

        cur.execute(
            "INSERT INTO målinger (timestamp, temperatur, fugt, device) VALUES (?, ?, ?, ?)",
            (
                data.get("timestamp", datetime.datetime.now().isoformat()),
                data.get("temperature"),
                data.get("humidity"),
                data.get("device", "esp32")
            )
        )

        conn.commit()
        conn.close()

    except Exception as e:
        print("Fejl i subscriber:", e)


client = mqtt.Client()
client.on_message = on_message

client.connect("localhost", 1883, 60)
client.subscribe("ventilation/telemetry")

print("Subscriber er startet og lytter på ventilation/telemetry...")
client.loop_forever()
