from fastapi import FastAPI
import psycopg2
import os

app = FastAPI()
DB_URL = os.getenv("DATABASE_URL", "postgresql://admin:quest@questdb:8812/qdb")

@app.get("/ping")
def ping():
    return {"status": "ok"}

@app.get("/api/v1/healthz")
def healthz():
    try:
        conn = psycopg2.connect(DB_URL)
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        conn.close()
        return {"status": "healthy"}
    except Exception as e:
        return {"status": "error", "details": str(e)}
