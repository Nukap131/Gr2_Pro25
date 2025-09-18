# Logging & Monitoring (ISO/IEC 27002:2022)

## Omfang
- **System**: journald (persistent), auth.log, kernel events  
- **Database**: auditd overvågning af SQLite databasen (fx `sensordata.db`)  
- **MQTT**: Mosquitto logs (error, warning, notice, information)  
- **Applikation**: spdlog i `paho-sub.cpp` (rotating file + JSON)  
- **Webserver**: nginx access/error logs  

## Bevarelse og rotation
- System logs roteres ugentligt, beholdes i 12 uger  
- Audit logs bevares i 90 dage  
- Mosquitto og nginx roteres via logrotate  
- Applikationslogs roteres (5 MB × 10 filer via spdlog)

## Adgang
- Kun `adm`-gruppen har læseadgang til logs  
- Ingen credentials eller følsomme data logges

## Eksempel-logs
Se eksempellogs i [`docs/logs/`](docs/logs/) for at se, hvordan Mosquitto og spdlog output kan se ud i praksis.  
De rigtige runtime-logs (journald, auditd, Mosquitto, spdlog, nginx) håndteres på systemet og roteres automatisk.
