#!/bin/bash
# ==========================================
#  WATCHDOG — PERIODISK TEST + AUTO GENSTART
# ==========================================

PROJECT="$HOME/tempprojekt"
LOGDIR="$PROJECT/logs"
mkdir -p "$LOGDIR"

while true; do
    LOGFILE="$LOGDIR/watchdog_$(date +'%Y-%m-%d_%H-%M-%S').log"
    echo "🔎 [$LOGFILE] Kører periodisk systemtest..."

    cd "$PROJECT/build" || exit 1
    ./tests/runTests > "$LOGFILE" 2>&1

    if grep -q "\[  FAILED  \]" "$LOGFILE"; then
        echo "❌ Fejl opdaget! Stopper systemet og logger fejl."
        date >> "$LOGDIR/critical.log"
        echo "Fejl under watchdog — se: $LOGFILE" >> "$LOGDIR/critical.log"

        # Stop alle services pænt
        pkill -f main.py
        pkill -f streamlit
        docker compose -f "$PROJECT/docker-compose.yml" down

        echo "⏳ Venter 2 minutter før genstart..."
        sleep 120

        echo "♻️  Genstarter systemet..."
        bash "$PROJECT/start_all.sh" &
        break
    fi

    # Vent 10 minutter (600 sekunder) før næste test
    sleep 600
done
