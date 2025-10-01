#!/bin/bash
# Script til at teste FastAPI endpoints
# Brug: ./test_fastapi.sh <SERVER_IP>

SERVER_IP=$1

if [ -z "$SERVER_IP" ]; then
  echo "⚠️  Brug: ./test_fastapi.sh <SERVER_IP>"
  echo "Eksempel lokalt: ./test_fastapi.sh localhost"
  exit 1
fi

echo "== Tester FastAPI på $SERVER_IP =="

echo "📡 Tester /ping"
curl -s http://$SERVER_IP:8080/ping && echo

echo "📡 Tester /api/v1/healthz"
curl -s http://$SERVER_IP:8080/api/v1/healthz && echo
