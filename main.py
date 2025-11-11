from fastapi import FastAPI
from fastapi.responses import JSONResponse
import sqlite3
from datetime import datetime

app = FastAPI(title="Temperature API", version="1.0")

# Health-check endpoint
@app.get("/health")
def health_check():
    return {"status": "ok", "timestamp": datetime.now().isoformat()}

# Eksempel: hent alle temperaturmålinger
@app.get("/measurements")
def get_measurements():
    try:
        conn = sqlite3.connect("sensordata.db")
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM temperature")
        data = cursor.fetchall()
        conn.close()
        return {"count": len(data), "data": data}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

if __name__ == "__main__":
    import uvicorn
    print("Starting API server...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
