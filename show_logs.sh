#!/bin/bash
LOG_DIR=~/tempprojekt/logs
mkdir -p "$LOG_DIR"

latest_stop=$(ls -t "$LOG_DIR"/stop_*.log 2>/dev/null | head -n 1)
latest_start=$(ls -t "$LOG_DIR"/start_*.log 2>/dev/null | head -n 1)

echo "======================================="
echo "  PROJEKT-LOGOVERSIGT"
echo "======================================="

if [ -n "$latest_start" ]; then
  echo "🟢 Seneste START-log:"
  echo "   $latest_start"
else
  echo "⚠ Ingen start-log fundet."
fi

if [ -n "$latest_stop" ]; then
  echo "🔴 Seneste STOP-log:"
  echo "   $latest_stop"
else
  echo "⚠ Ingen stop-log fundet."
fi

echo "---------------------------------------"
read -p "Vil du se (s)tart, (p)stop eller (a)begge? " choice

case "$choice" in
  s|S) cat "$latest_start" ;;
  p|P) cat "$latest_stop" ;;
  a|A) cat "$latest_start"; echo; cat "$latest_stop" ;;
  *) echo "Annulleret." ;;
esac
