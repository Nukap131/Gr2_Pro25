#!/bin/bash
set -e

BASE_DIR="$HOME/tempprojekt"
LOG_DIR="$BASE_DIR/logs"
API_PID="$BASE_DIR/api.pid"
SUB_PID="$BASE_DIR/subscriber.pid"
HEALTH_PID="$BASE_DIR/health.pid"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/stop_$(date '+%Y-%m-%d_%H-%M-%S').log"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo "=======================================" | tee -a "$LOG_FILE"
echo "🛑 STOPPER VENTILATIONSPROJEKT" | tee -a "$LOG_FILE"
echo "=======================================" | tee -a "$LOG_FILE"



# 1️⃣ Stop API
echo "[1/6] Stopper API..." | tee -a "$LOG_FILE"
if [ -f "$API_PID" ]; then
    PID=$(cat "$API_PID")
    kill "$PID" 2>/dev/null && echo "[OK] API stoppet" || echo "[INFO] API kørte ikke"
    rm "$API_PID"
else
    echo "[INFO] Ingen api.pid fundet"
fi


# 2️⃣ Stop subscriber
echo "[2/6] Stopper MQTT Subscriber..." | tee -a "$LOG_FILE"
if [ -f "$SUB_PID" ]; then
    PID=$(cat "$SUB_PID")
    kill "$PID" 2>/dev/null && echo "[OK] Subscriber stoppet" || echo "[INFO] Subscriber kørte ikke"
    rm "$SUB_PID"
else
    echo "[INFO] Ingen subscriber.pid fundet"
fi


# 3️⃣ Stop health
echo "[3/6] Stopper Health-monitor..." | tee -a "$LOG_FILE"
if [ -f "$HEALTH_PID" ]; then
    PID=$(cat "$HEALTH_PID")
    kill "$PID" 2>/dev/null && echo "[OK] Health stoppet" || echo "[INFO] Health kørte ikke"
    rm "$HEALTH_PID"
else
    echo "[INFO] Ingen health.pid fundet"
fi


# 4️⃣ Stop Streamlit
echo "[4/6] Stopper Streamlit..." | tee -a "$LOG_FILE"
pkill -f "streamlit run" && echo "[OK] Streamlit stoppet" || echo "[INFO] Streamlit kørte ikke"


# 5️⃣ Stop Docker
echo "[5/6] Stopper Docker..." | tee -a "$LOG_FILE"
docker compose down >> "$LOG_FILE" 2>&1
echo "[OK] Docker stoppet"


# 6️⃣ Stop Mosquitto
echo "[6/6] Stopper Mosquitto..." | tee -a "$LOG_FILE"
sudo systemctl stop mosquitto && echo "[OK] Mosquitto stoppet"


echo "---------------------------------------" | tee -a "$LOG_FILE"
echo "✅ SYSTEMET ER FULDT STOPPET"
echo "---------------------------------------"
