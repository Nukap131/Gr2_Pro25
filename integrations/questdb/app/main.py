from fastapi import FastAPI
from fastapi.responses import StreamingResponse
import psycopg2
import os
import io
import csv
from datetime import datetime

# -------- APP --------
app = FastAPI()

# DB config (QuestDB via Postgres wire protocol)
DB_URL = os.getenv("DATABASE_URL", "postgresql://admin:quest@questdb:8812/qdb")

# -------- PING ENDPOINT --------
@app.get("/ping")
def ping():
    return {"status": "ok"}

# -------- HEALTH ENDPOINT --------
@app.get("/api/v1/healthz")
def healthz():
    try:
        conn = psycopg2.connect(DB_URL)
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        conn.close()
        return {"status": "healthy"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}

# -------- FLEXIBLE INSERT --------
@app.post("/insert")
def insert_data(payload: dict):
    try:
        ts = payload.get("ts", datetime.utcnow().isoformat())
        device_id = payload.get("device_id", "vent01")
        metric = payload.get("metric")
        value = payload.get("value")

        if metric is None or value is None:
            return {"error": "Payload skal indeholde 'metric' og 'value'"}

        conn = psycopg2.connect(DB_URL)
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO ventilation_data (ts, device_id, metric, value)
            VALUES (%s, %s, %s, %s);
        """, (ts, device_id, metric, value))
        conn.commit()
        conn.close()

        return {"status": "ok", "inserted": payload}
    except Exception as e:
        return {"error": str(e)}

# -------- EXPORT AS CSV --------
@app.get("/export")
def export_data():
    try:
        conn = psycopg2.connect(DB_URL)
        cur = conn.cursor()
        cur.execute("SELECT ts, device_id, metric, value FROM ventilation_data ORDER BY ts DESC LIMIT 100;")
        rows = cur.fetchall()
        conn.close()

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["ts", "device_id", "metric", "value"])
        for row in rows:
            writer.writerow(row)
        output.seek(0)

        return StreamingResponse(iter([output.getvalue()]),
                                 media_type="text/csv",
                                 headers={"Content-Disposition": "attachment; filename=ventilation_data.csv"})
    except Exception as e:
        return {"error": str(e)}
