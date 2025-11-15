#!/bin/bash
set -e

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
# 1️⃣ Aktivér virtuelt miljø
# ================================
echo -e "[1/7] Aktiverer virtuelt miljø..."
source "$VENV"
echo -e "${GREEN}[OK] Virtuelt miljø aktiveret${RESET}" | tee -a "$LOG_FILE"

# ================================
# 2️⃣ Start Mosquitto (før tests!)
# ================================
echo -e "[2/7] Starter Mosquitto broker..."
if ! systemctl is-active --quiet mosquitto; then
  sudo systemctl start mosquitto
  sleep 2
fi

if systemctl is-active --quiet mosquitto; then
  echo -e "${GREEN}[OK] Mosquitto kører${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}[FEJL] Mosquitto kunne ikke startes${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# ================================
# 3️⃣ Kør C++ unit tests (Mosquitto kører → testen består)
# ================================
echo -e "[3/7] Kører C++ unit tests..."
cd "$BASE_DIR/build"
if ./tests/runTests >> "$LOG_FILE" 2>&1; then
  echo -e "${GREEN}[OK] Tests bestået${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}[FEJL] Tests fejlede${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# ================================
# 4️⃣ Start Docker-containere
# ================================
echo -e "[4/7] Starter Docker..."
cd "$BASE_DIR"
docker compose up -d >> "$LOG_FILE" 2>&1
echo -e "${GREEN}[OK] Docker kører${RESET}" | tee -a "$LOG_FILE"

# ================================
# 5️⃣ Start MQTT-subscriber
# ================================
echo -e "[5/7] Starter subscriber..."

SUB_PID="$BASE_DIR/subscriber.pid"
SUB_LOG="$LOG_DIR/subscriber.log"

nohup python3 "$BASE_DIR/subscriber.py" >> "$SUB_LOG" 2>&1 &
echo $! > "$SUB_PID"
sleep 1

echo -e "${GREEN}[OK] Subscriber startet (PID $(cat "$SUB_PID"))${RESET}" | tee -a "$LOG_FILE"

# ================================
# 6️⃣ Start Streamlit-dashboard
# ================================
echo -e "[6/7] Starter Streamlit..."
nohup streamlit run "$BASE_DIR/app.py" --server.port 8501 >> "$LOG_FILE" 2>&1 &
sleep 3
echo -e "${GREEN}[OK] Streamlit kører${RESET}" | tee -a "$LOG_FILE"

# ================================
# 7️⃣ Samlet status
# ================================
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ SYSTEMET ER KLART${RESET}" | tee -a "$LOG_FILE"
echo "Mosquitto → 1883" | tee -a "$LOG_FILE"
echo "Subscriber PID → $(cat "$SUB_PID")" | tee -a "$LOG_FILE"
echo "Streamlit → http://localhost:8501" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"
