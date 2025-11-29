#!/bin/bash
set -e

BASE_DIR="$HOME/tempprojekt"
VENV="$BASE_DIR/venv/bin/activate"
LOG_DIR="$BASE_DIR/logs"
API_PID="$BASE_DIR/api.pid"
SUB_PID="$BASE_DIR/subscriber.pid"
HEALTH_PID="$BASE_DIR/health.pid"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/start_$(date '+%Y-%m-%d_%H-%M-%S').log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}======================================="
echo -e "🚀 STARTER HELE VENTILATIONSPROJEKTET"
echo -e "=======================================${RESET}"
echo "Starttid: $(date)" | tee -a "$LOG_FILE"
echo "Logfil: $LOG_FILE" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"


# 1️⃣ Aktiver venv
echo -e "[1/8] Aktiverer Python virtualenv..."
source "$VENV"
echo -e "${GREEN}[OK] venv aktiveret${RESET}" | tee -a "$LOG_FILE"


# 2️⃣ Start Mosquitto
echo -e "[2/8] Starter Mosquitto..."
if ! systemctl is-active --quiet mosquitto; then
  sudo systemctl start mosquitto
  sleep 1
fi
echo -e "${GREEN}[OK] Mosquitto kører${RESET}" | tee -a "$LOG_FILE"


# 3️⃣ Kør C++ unit tests
echo -e "[3/8] Kører C++ tests..."
cd "$BASE_DIR/build"
if ./tests/runTests >> "$LOG_FILE" 2>&1; then
    echo -e "${GREEN}[OK] Tests bestået${RESET}"
else
    echo -e "${RED}[FEJL] Tests fejlede${RESET}"
    exit 1
fi


# 4️⃣ Start Docker (questdb + hvad der ellers ligger)
echo -e "[4/8] Starter Docker..."
cd "$BASE_DIR"
docker compose up -d >> "$LOG_FILE" 2>&1
echo -e "${GREEN}[OK] Docker kører${RESET}" | tee -a "$LOG_FILE"


# 5️⃣ Start health-monitor
echo -e "[5/8] Starter Health-monitor..."
nohup "$BASE_DIR/health" >> "$BASE_DIR/systemlog.txt" 2>&1 &
echo $! > "$HEALTH_PID"
echo -e "${GREEN}[OK] Health-monitor startede (PID $(cat "$HEALTH_PID"))${RESET}"


# 6️⃣ Start subscriber
echo -e "[6/8] Starter Subscriber..."
nohup python3 "$BASE_DIR/subscriber.py" >> "$LOG_DIR/subscriber.log" 2>&1 &
echo $! > "$SUB_PID"
echo -e "${GREEN}[OK] Subscriber startede (PID $(cat "$SUB_PID"))${RESET}"


# 7️⃣ Start FastAPI
echo -e "[7/8] Starter FastAPI..."
nohup uvicorn main:app --host 0.0.0.0 --port 8001 >> "$LOG_DIR/api.log" 2>&1 &
echo $! > "$API_PID"
echo -e "${GREEN}[OK] API startede (PID $(cat "$API_PID"))${RESET}"


# 8️⃣ Start Streamlit
echo -e "[8/8] Starter Streamlit Dashboard..."
nohup streamlit run "$BASE_DIR/app.py" --server.port 8501 >> "$LOG_DIR/streamlit.log" 2>&1 &
echo -e "${GREEN}[OK] Streamlit kører på http://localhost:8501${RESET}"


echo -e "${GREEN}======================================="
echo -e "   🎉 HELE SYSTEMET ER NU KLAR"
echo -e "=======================================${RESET}"
