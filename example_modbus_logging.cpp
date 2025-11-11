/**
 * @file example_modbus_logging.cpp
 * @brief Demonstration af Modbus-datalogning for ventilationssystemet.
 *
 * Denne fil viser, hvordan ESP32-POE sender Modbus-registerdata
 * til Debian-backend, hvor data gemmes i SQLite og logges med spdlog.
 */

 * hvor værdierne logges med spdlog og gemmes i SQLite.
 *
 * @code
 *  DataLogger logger("modbus_data.db", "systemlog.txt");
 *  logger.insertRegisterValue("2025-11-10 17:30:00", 1, 30001, 22.5); // Temperatur
 *  logger.insertRegisterValue("2025-11-10 17:30:00", 1, 30002, 150.0); // Luftmængde
 *  logger.insertRegisterValue("2025-11-10 17:30:00", 1, 30003, 1);     // Status
 *  logger.close();
 * @endcode
 */

#include "DataLogger.h"

int main() {
    DataLogger logger("modbus_data.db", "systemlog.txt");
    logger.insertRegisterValue("2025-11-10 17:30:00", 1, 30001, 22.5);
    logger.insertRegisterValue("2025-11-10 17:30:00", 1, 30002, 150.0);
    logger.insertRegisterValue("2025-11-10 17:30:00", 1, 30003, 1);
    logger.close();
    return 0;
}
