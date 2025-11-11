#!/bin/bash
clear
echo "======================================="
echo "  STOPPER VENTILATIONSPROJEKT"
echo "======================================="
#!/bin/bash
set -e

# ================================
#  SYSTEM KONFIGURATION
# ================================
BASE_DIR="$HOME/tempprojekt"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/stop_$(date '+%Y-%m-%d_%H-%M-%S').log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}======================================="
echo -e "🛑 STOPPER VENTILATIONSPROJEKT"
echo -e "=======================================${RESET}"
echo "Stoptid: $(date)" | tee -a "$LOG_FILE"
echo "Logfil: $LOG_FILE" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"

# ================================
# 1️⃣  Stopper Streamlit-dashboard
# ================================
echo -e "[1/6] Stopper Streamlit-dashboard..."
if pgrep -f "streamlit run" >/dev/null; then
  pkill -f "streamlit run"
  sleep 2
  if pgrep -f "streamlit run" >/dev/null; then
    echo -e "${RED}[FEJL] Streamlit kunne ikke lukkes${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[OK] Streamlit stoppet${RESET}" | tee -a "$LOG_FILE"
  fi
else
  echo -e "${YELLOW}[INFO] Streamlit kørte ikke${RESET}" | tee -a "$LOG_FILE"
fi

# ================================
# 2️⃣  Stopper Docker-containere (QuestDB + FastAPI)
# ================================
echo -e "[2/6] Stopper Docker-containere..."
cd "$BASE_DIR"
if docker compose down >> "$LOG_FILE" 2>&1; then
  echo -e "${GREEN}[OK] Docker-containere stoppet${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}[FEJL] Kunne ikke stoppe Docker${RESET}" | tee -a "$LOG_FILE"
fi

# ================================
# 3️⃣  Tjekker Mosquitto (systemd)
# ================================
echo -e "[3/6] Kontrollerer Mosquitto-status..."
if systemctl is-active --quiet mosquitto; then
  echo -e "${YELLOW}[INFO] Mosquitto fortsætter (systemd)${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${GREEN}[OK] Mosquitto allerede inaktiv${RESET}" | tee -a "$LOG_FILE"
fi

# ================================
# 4️⃣  Deaktiverer virtuelt miljø
# ================================
echo -e "[4/6] Deaktiverer virtuelt miljø..."
if [[ "$VIRTUAL_ENV" != "" ]]; then
  deactivate || true
  echo -e "${GREEN}[OK] Virtuelt miljø deaktiveret${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${YELLOW}[INFO] Intet aktivt virtuelt miljø${RESET}" | tee -a "$LOG_FILE"
fi

# ================================
# 5️⃣  Rydder gamle logs (>7 dage)
# ================================
echo -e "[5/6] Rydder gamle logfiler..."
find "$LOG_DIR" -type f -mtime +7 -name "*.log" -exec rm -f {} \;
echo -e "${GREEN}[OK] Gamle logfiler fjernet${RESET}" | tee -a "$LOG_FILE"

# ================================
# 6️⃣  Samlet status
# ================================
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ SYSTEMET ER NU STANSET${RESET}" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo "Tjenester stoppet:" | tee -a "$LOG_FILE"
echo " - Streamlit-dashboard" | tee -a "$LOG_FILE"
echo " - Docker (FastAPI + QuestDB)" | tee -a "$LOG_FILE"
echo " - Virtuelt miljø deaktiveret" | tee -a "$LOG_FILE"
echo " - Mosquitto forbliver kørende (systemd)" | tee -a "$LOG_FILE"
echo "---------------------------------------" | tee -a "$LOG_FILE"
echo "Stoplog gemt: $LOG_FILE" | tee -a "$LOG_FILE"
echo -e "${CYAN}=======================================${RESET}" | tee -a "$LOG_FILE"
