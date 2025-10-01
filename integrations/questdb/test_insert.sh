#!/bin/bash
# Script til at indsætte og læse data i QuestDB

echo "📥 Opretter tabel hvis den ikke findes..."
psql "postgresql://admin:quest@localhost:8812/qdb" <<EOF
CREATE TABLE IF NOT EXISTS sensor_data (
    ts TIMESTAMP,
    device_id SYMBOL,
    value DOUBLE
) timestamp(ts);
EOF

echo "✅ Indsætter testdata..."
psql "postgresql://admin:quest@localhost:8812/qdb" <<EOF
INSERT INTO sensor_data (ts, device_id, value) VALUES (now(), 'test_device', 123.45);
EOF

echo "📊 Viser de seneste rækker:"
psql "postgresql://admin:quest@localhost:8812/qdb" <<EOF
SELECT * FROM sensor_data ORDER BY ts DESC LIMIT 5;
EOF
