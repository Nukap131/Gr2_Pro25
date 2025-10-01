#!/bin/bash
TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Brug: ./test_fastapi.sh <host>"
  exit 1
fi

echo "== Tester FastAPI på $TARGET =="
echo "📡 Tester /ping"
curl -s http://$TARGET:8080/ping && echo
echo "📡 Tester /api/v1/healthz"
curl -s http://$TARGET:8080/api/v1/healthz && echo
