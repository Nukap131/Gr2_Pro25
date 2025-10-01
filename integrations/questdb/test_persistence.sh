#!/bin/bash
# Test persistence for QuestDB + FastAPI
# Stopper containerne, starter dem igen og tjekker om data stadig er der

echo "⏹ Stopper containerne..."
docker compose down

echo "⏫ Starter containerne igen..."
docker compose up -d

sleep 5  # giver containerne tid til at starte

echo "📊 Checker om data stadig findes i QuestDB..."
psql "postgresql://admin:quest@localhost:8812/qdb" <<EOF
SELECT * FROM sensor_data ORDER BY ts DESC LIMIT 5;
EOF

echo "✅ Test færdig. Hvis rækker vises, virker persistence!"
