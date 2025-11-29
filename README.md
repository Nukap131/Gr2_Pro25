# Ventilationsmonitoreringssystem – IoT Projekt (2025)

Dette repository indeholder et komplet IoT-baseret monitoreringssystem til et ventilationsanlæg.  
Systemet kan køre på enhver Linux-maskine (f.eks. Debian), og er opbygget af microservices, der kommunikerer via MQTT, HTTP og QuestDB.

Systemet anvender:
- **FastAPI** (REST API)
- **Mosquitto MQTT broker**
- **QuestDB** (time-series database)
- **Streamlit Dashboard**
- **Subscriber (Python)** med realistisk datagenerering
- **Docker Compose** til at samle hele systemet
- **Doxygen** til dokumentation
- **Watchdog** og logging for stabil drift

Projektet er udviklet som en del af IT-Teknolog uddannelsen på UCL.

---

## 📦 Projektstruktur

tempprojekt/
│
├── api/ # FastAPI backend
├── dashboard/ # Streamlit dashboard
├── subscriber/ # MQTT subscriber + Realistisk datasimulator
│
├── docs/ # Doxygen-konfiguration og genereret dokumentation
├── logs/ # Log-mapper (indeholder .gitkeep)
│
├── docker-compose.yml # Samler alle services
├── start_all.sh # Starter hele systemet
├── start_clean.sh # Ren start uden cache
├── stop_all.sh # Stopper alle containers

yaml
Kopier kode

---

## 🚀 Hurtig start

### 1. Klon projektet
```bash
git clone https://github.com/Nukap131/Gr2_Pro25.git
cd Gr2_Pro25
2. Start hele systemet
bash
Kopier kode
./start_all.sh
Dette script starter automatisk:

Mosquitto MQTT broker

QuestDB (HTTP + ILP ports)

Subscriber

FastAPI

Streamlit Dashboard

Healthmonitor

3. Adgang til tjenester
Service	URL
Dashboard	http://localhost:8501
FastAPI docs	http://localhost:8000/docs
QuestDB UI	http://localhost:9000
MQTT broker	Port 1883

🧱 Systemarkitektur
css
Kopier kode
[Subscriber.py] → MQTT → [Mosquitto] → FastAPI → QuestDB → Dashboard
Subscriber genererer realistiske temperatur-, tryk-, CO₂- og luftflow-data

Sender data via MQTT

FastAPI validerer og skriver til QuestDB

Dashboard henter data via REST og viser KPIs, grafer, alarmer og rådata

📡 API Endpoints (FastAPI)
Hent målinger
bash
Kopier kode
GET /maalinger?limit=200
Healthchecks
bash
Kopier kode
GET /health
GET /health/mqtt
GET /health/db
GET /health/api
Alle endpoints returnerer HTTP 200 ved OK og 500 ved fejl.

📊 Dashboard
Dashboardet viser:

KPI-boks med seneste måling

Samlet graf med alle parametre

Individuelle grafer med alarmgrænser

Alarmstatus (seneste 50 målinger)

Alarmhistorik

Download som CSV

Rådatatabel (seneste 10 målinger)

🗄 QuestDB
Subscriber sender data via Influx Line Protocol (ILP) til port 9009.

Eksempel på ILP-linje:

Kopier kode
maalinger,device=Ventilationsanlaeg udendoers_temp=4.8,rum_temp=21.0,tilluft_temp=10.5,effektforbrug=203.3,virkningsgrad=76.4 1701096520123456789
🔍 Logging
Alle services logger til:

bash
Kopier kode
logs/api/
logs/dashboard/
logs/subscriber/
logs/mosquitto/
logs/questdb/
Da logfiler ændrer sig konstant, indeholder repoet kun .gitkeep-filer for at bevare strukturen.

Eksempel på API-log:

csharp
Kopier kode
[INFO] NY måling modtaget
[INFO] Skrevet til QuestDB
📚 Doxygen
Doxygen bruges til at dokumentere:

Kode i API, subscriber og scripts

Flow mellem services

Systemets overordnede design

Doxygen-konfigurationen ligger i:

Kopier kode
docs/Doxyfile
Genereret HTML ligger lokalt i:

bash
Kopier kode
docs/html/index.html
I rapportens bilag findes screenshots af dokumentationen.

🛡 Watchdog & Health Monitor
Systemet indeholder watchdog-script, der:

Checker om alle containers kører

Genstarter automatisk, hvis en service stopper

Logger status til logs/health/

Dette øger driftssikkerheden markant.

⚙️ Stop systemet
bash
Kopier kode
./stop_all.sh
📄 Licens
Projektet er udviklet til uddannelsesbrug (UCL IT-Teknolog 2025).
