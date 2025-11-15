from fastapi import FastAPI
from fastapi.responses import JSONResponse
import sqlite3
from datetime import datetime

DB_PATH = "/app/sensordata.db"

app = FastAPI(title="Ventilations API", version="1.0")

@app.get("/health")
def health():
    return {"status": "ok", "timestamp": datetime.now().isoformat()}

@app.get("/measurements")
def get_measurements():
    try:
        conn = sqlite3.connect(DB_PATH)
        cur = conn.cursor()
        cur.execute("SELECT timestamp, temperatur, fugt, device FROM målinger ORDER BY rowid DESC LIMIT 200")
        rows = cur.fetchall()
        conn.close()
        return rows
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})
