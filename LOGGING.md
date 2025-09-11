# Logging & Monitoring (ISO/IEC 27002:2022)

## Omfang
- **System**: journald (persistent), auth.log, kernel events  
- **Database**: auditd overvågning af `/root/tempprojekt/sensordata.db`  
- **MQTT**: Mosquitto logs (error, warning, notice, information)  
- **Applikation**: spdlog i paho-sub.cpp (rotating file + JSON)

## Bevarelse og rotation
- System logs roteres ugentligt, beholdes i 12 uger  
- Audit logs bevares i 90 dage  
- Mosquitto og nginx roteres via logrotate  
- App-logs roteres (5 MB × 10 filer)

## Adgang
- Kun `adm`-gruppen har læseadgang til logs  
- Ingen credentials eller følsomme data logges

## Overvågning og alarmer
- Auth failures > 5 pr. minut → alarm  
- Mange MQTT disconnects på kort tid → alarm  
- Audit hit på databasefil → rapporteres
