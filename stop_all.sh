#!/bin/bash
set -e

BASE_DIR="$HOME/tempprojekt"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/stop_$(date '+%Y-%m-%d_%H-%M-%S').log"

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo "=======================================" | tee -a "$LOG_FILE"
echo "🛑 STOPPER VENTILATIONSPROJEKT" | tee -a "$LOG_FILE"
echo "=======================================" | tee -a "$LOG_FILE"

# ================================
# 1️⃣ Stop subscriber
# ================================
echo -e "[1/5] Stopper subscriber..." | tee -a "$LOG_FILE"
SUB_PID="$BASE_DIR/subscriber.pid"

if [ -f "$SUB_PID" ]; then
  PID=$(cat "$SUB_PID")
  if ps -p $PID >/dev/null 2>&1; then
    kill $PID
    echo -e "${GREEN}[OK] Subscriber stoppet${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${YELLOW}[INFO] Subscriber PID fandtes men kørte ikke${RESET}" | tee -a "$LOG_FILE"
  fi
  rm "$SUB_PID"
else
  echo -e "${YELLOW}[INFO] Ingen subscriber.pid fundet${RESET}" | tee -a "$LOG_FILE"
fi

# ================================
# 2️⃣ Stop Streamlit
# ================================
echo -e "[2/5] Stopper Streamlit..." | tee -a "$LOG_FILE"
pkill -f "streamlit run" && \
  echo -e "${GREEN}[OK] Streamlit stoppet${RESET}" | tee -a "$LOG_FILE" || \
  echo -e "${YELLOW}[INFO] Streamlit kørte ikke${RESET}" | tee -a "$LOG_FILE"

# ================================
# 3️⃣ Stop Docker
# ================================
echo -e "[3/5] Stopper Docker..." | tee -a "$LOG_FILE"
docker compose down >> "$LOG_FILE" 2>&1 && \
  echo -e "${GREEN}[OK] Docker stoppet${RESET}" | tee -a "$LOG_FILE"

# ================================
# 4️⃣ Stop Mosquitto
# ================================
echo -e "[4/5] Stopper Mosquitto..." | tee -a "$LOG_FILE"
sudo systemctl stop mosquitto && \
  echo -e "${GREEN}[OK] Mosquitto stoppet${RESET}" | tee -a "$LOG_FILE"

# ================================
# 5️⃣ Afslut
# ================================
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ SYSTEMET ER STOPPET${RESET}" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"
