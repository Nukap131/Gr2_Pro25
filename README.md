# FastAPI + QuestDB Demo

Dette projekt viser, hvordan man bygger en REST API med [FastAPI](https://fastapi.tiangolo.com/), kobler den til [QuestDB](https://questdb.io/) og dockeriserer det hele.  
API’et kører over **HTTPS** (self-signed certifikat til demo).

---

## Quickstart

Klon projektet og start med Docker Compose:

```bash
git clone https://github.com/Nukap131/Gr2_Pro25.git
cd fastapi-questdb
docker compose up -d --build
```

---

## Services

Når containere kører, har du adgang til:

- **FastAPI (Swagger UI)** → https://localhost:8000/docs  
- **QuestDB Console** → http://localhost:9000  

## Healthchecks

Dette projekt benytter nu Docker healthchecks:

- **QuestDB** → Tjekker med `curl` om webkonsollen på port **9000** svarer.  
- **FastAPI** → Tjekker med `curl` om endpointet **/ping** svarer korrekt.  

Healthchecks gør, at Docker automatisk kan afgøre om services kører som forventet.  
Du kan se status med:

```bash
docker ps


---

## Endpoints

### GET /ping  
Healthcheck – svarer hvis API’et kører  
```bash
curl -k https://localhost:8000/ping
```

### GET /api/v1/healthz  
Tjekker DB-forbindelse  
```bash
curl -k https://localhost:8000/api/v1/healthz
```

### POST /api/v1/sensor  
Indsætter en ny måling  
```bash
curl -k -X POST https://localhost:8000/api/v1/sensor \
  -H "Content-Type: application/json" \
  -d '{"device_id":"esp32-01","temp":22.5,"hum":44.0}'
```

### GET /api/v1/sensor?limit=5  
Henter seneste målinger  
```bash
curl -k "https://localhost:8000/api/v1/sensor?limit=5"
```

---

## Test

Efter opstart kan du teste API’et direkte med curl-kommandoerne ovenfor eller åbne Swagger UI på:  
👉 https://localhost:8000/docs

---

## QuestDB + FastAPI Integration

### Opsætning
- Docker Compose med:
  - QuestDB (port 9000, 8812, 9009)
  - FastAPI (port 8080)
- Persistente data via Docker volumes

### Test scripts
- `test_fastapi.sh` → tester `/ping` og `/api/v1/healthz`
- `test_insert.sh` → indsætter testdata i QuestDB
- `test_persistence.sh` → stopper og starter containerne, tjekker om data stadig er der

### Kørsel
```bash
docker compose up -d --build
./test_insert.sh
./test_fastapi.sh localhost
./test_persistence.sh
