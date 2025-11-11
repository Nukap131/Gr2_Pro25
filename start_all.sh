#!/bin/bash
set -e

# ================================
#  SYSTEM KONFIGURATION
# ================================
BASE_DIR="$HOME/tempprojekt"
VENV="$BASE_DIR/venv/bin/activate"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/start_$(date '+%Y-%m-%d_%H-%M-%S').log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}======================================="
echo -e "🚀 STARTER VENTILATIONSPROJEKT"
echo -e "=======================================${RESET}"
echo "Starttid: $(date)" | tee -a "$LOG_FILE"
echo "Logfil: $LOG_FILE" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"

# ================================
# 1️⃣  Aktivér virtuelt miljø
# ================================
echo -e "[1/6] Aktiverer virtuelt miljø..."
if source "$VENV" 2>/dev/null; then
  echo -e "${GREEN}[OK] Virtuelt miljø aktiveret${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}[FEJL] Kunne ikke aktivere venv${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# ================================
# 2️⃣  Kør unit tests (GTest)
# ================================
echo -e "[2/6] Kører C++ unit tests (GTest)..."
cd "$BASE_DIR/build"
if ./tests/runTests >> "$LOG_FILE" 2>&1; then
  echo -e "${GREEN}[OK] Alle C++ tests bestået${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}[FEJL] En eller flere tests fejlede – se logfil${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# ================================
# 3️⃣  Start Docker-containere
# ================================
echo -e "[3/6] Starter Docker-containere..."
cd "$BASE_DIR"
if docker compose up -d >> "$LOG_FILE" 2>&1; then
  echo -e "${GREEN}[OK] Docker-containere kører${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}[FEJL] Kunne ikke starte Docker${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# ================================
# 4️⃣  Kontroller Mosquitto-broker
# ================================
echo -e "[4/6] Kontrollerer Mosquitto..."
if systemctl is-active --quiet mosquitto; then
  echo -e "${GREEN}[OK] Mosquitto kører via systemd${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${YELLOW}[INFO] Mosquitto kører ikke – forsøger at starte...${RESET}" | tee -a "$LOG_FILE"
  sudo systemctl start mosquitto
  sleep 3
  if systemctl is-active --quiet mosquitto; then
    echo -e "${GREEN}[OK] Mosquitto startet${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[FEJL] Kunne ikke starte Mosquitto${RESET}" | tee -a "$LOG_FILE"
    exit 1
  fi
fi

# ================================
# 5️⃣  Start Streamlit-dashboard
# ================================
echo -e "[5/6] Starter Streamlit-dashboard..."
if pgrep -f "streamlit run" >/dev/null; then
  echo -e "${YELLOW}[INFO] Streamlit kører allerede${RESET}" | tee -a "$LOG_FILE"
else
  nohup streamlit run "$BASE_DIR/app.py" --server.port 8501 >> "$LOG_FILE" 2>&1 &
  sleep 4
  if pgrep -f "streamlit run" >/dev/null; then
    echo -e "${GREEN}[OK] Streamlit kører på http://localhost:8501${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[FEJL] Streamlit kunne ikke startes${RESET}" | tee -a "$LOG_FILE"
    exit 1
  fi
fi

# ================================
# 6️⃣  Samlet status
# ================================
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ SYSTEMET ER KLAR${RESET}" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo "Tjenester:" | tee -a "$LOG_FILE"
echo " - FastAPI  →  http://localhost:8000/docs" | tee -a "$LOG_FILE"
echo " - QuestDB  →  http://localhost:9000" | tee -a "$LOG_FILE"
echo " - Streamlit → http://localhost:8501" | tee -a "$LOG_FILE"
echo " - MQTT broker → port 1883 (systemd)" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo "Stop script:  ./stop_all.sh" | tee -a "$LOG_FILE"
echo "Log gemt:     $LOG_FILE" | tee -a "$LOG_FILE"
echo "=======================================" | tee -a "$LOG_FILE"
