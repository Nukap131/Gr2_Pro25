# FastAPI + QuestDB Demo

Dette projekt viser, hvordan man bygger en REST API med [FastAPI](https://fastapi.tiangolo.com/), kobler den til [QuestDB](https://questdb.io/) og dockeriserer det hele.  
API’et kører over **HTTPS** (self-signed certifikat til demo).

---

## Quickstart

Klon projektet og start med Docker Compose:

```bash
git clone https://github.com/Vissing96/fastapi-questdb.git
cd fastapi-questdb
docker compose up -d --build
```

---

## Services

Når containere kører, har du adgang til:

- **FastAPI (Swagger UI)** → https://localhost:8000/docs  
- **QuestDB Console** → http://localhost:9000  

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

