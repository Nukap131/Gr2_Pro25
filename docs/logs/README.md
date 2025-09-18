# Eksempel-logs

Denne mappe indeholder **eksempler** på logfiler fra projektet.  
De viser hvordan log-output kan se ud, men er ikke reelle drift-logs.

## Indeholder
- `spdlog_example.log` → eksempel på applikationslog fra spdlog
- `mosquitto_example.log` → eksempel på broker-log fra Mosquitto

## Bemærk
- Rigtige runtime-logs (journald, auditd, Mosquitto, spdlog, nginx) ligger på systemet og roteres via logrotate.
- Disse filer er kun med i repoet for dokumentation og illustration.
