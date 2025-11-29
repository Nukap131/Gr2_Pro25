import requests
import logging
from fastapi import FastAPI
from logging.handlers import RotatingFileHandler
from mqtt_handler import start_mqtt_listener

# ==========================================================
#  LOGGING
# ==========================================================
log = logging.getLogger("api")
log.setLevel(logging.INFO)

# Filhandler
fh = logging.FileHandler("/var/log/api/api.log")
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

log.info("API container starter ...")


# ==========================================================
#  FASTAPI
# ==========================================================
app = FastAPI(
    title="Ventilations API - Model A",
    version="1.0"
)

READ_URL = "http://questdb:9000/exec"

log.info("Starter MQTT → QuestDB listener ...")
start_mqtt_listener()


# ==========================================================
#  ENDPOINTS
# ==========================================================
@app.get("/health")
def health():
    log.info("Health endpoint kaldt")
    return {"status": "ok"}


@app.get("/maalinger")
def get_data(limit: int = 200):

    log.info(f"/maalinger endpoint kaldt med limit={limit}")

    sql = f"""
        SELECT device,
               udendoers_temp,
               rum_temp,
               tilluft_temp,
               effektforbrug,
               virkningsgrad,
               timestamp
        FROM maalinger
        ORDER BY timestamp DESC
        LIMIT {limit}
    """

    try:
        r = requests.get(READ_URL, params={"query": sql})
        r.raise_for_status()
    except Exception as e:
        log.error(f"QuestDB forespørgsel FEJLEDE: {e}")
        return {"error": "Kunne ikke hente data fra QuestDB"}

    data = r.json()
    columns = [c["name"] for c in data["columns"]]
    rows = data["dataset"]

    log.info(f"Hentede {len(rows)} rækker fra QuestDB")

    return [
        {columns[i]: row[i] for i in range(len(columns))}
        for row in rows
    ]
