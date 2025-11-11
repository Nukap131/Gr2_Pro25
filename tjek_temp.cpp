/**
 * @file tjek_temp.cpp
 * @brief Tester spdlog-logning for ventilationsprojektet.
 *
 * Denne fil demonstrerer systemets logningsmekanisme som en del af
 * ventilationsovervågningssystemet. Programmet simulerer aflæsning af
 * en sensorværdi og viser, hvordan både information, advarsler og fejl
 * håndteres og gemmes i systemlogfilen.
 *
 * @details
 * Logningen bruges til at dokumentere systemets driftstilstand,
 * så fejl, sensoraflæsninger og hændelser kan spores. Dette er en
 * del af virksomhedens dokumentationskrav for temperatur- og
 * luftkvalitetsdata.
 *
 * @author Victor
 * @version 1.0
 * @date 2025-11-10
 */


#include "spdlog/spdlog.h"
#include "spdlog/sinks/basic_file_sink.h"
#include <iostream>

/**
 * @brief Main-funktion der tester logning med spdlog.
 *
 * Opretter en logger, skriver forskellige typer beskeder
 * (info, advarsel, fejl) og lukker loggeren ned på en
 * sikker måde. Alle beskeder gemmes i systemlog.txt.
 *
 * @return int Returnerer 0, hvis programmet afsluttes korrekt.
 */
int main() {
    try {
        // Opretter en basic file logger, der skriver til "systemlog.txt"
        auto logger = spdlog::basic_logger_mt("file_logger", "systemlog.txt");

        // Informationsbeskeder
        logger->info("System startet");
        logger->info("Sensorværdi læst: {}", 23.7);

        // Advarsel
        logger->warn("Lav spænding målt");

        // Fejl
        logger->error("Fejl: Sensor ikke forbundet");

        // Luk loggeren ned korrekt
        spdlog::shutdown();
    } catch (const spdlog::spdlog_ex &ex) {
        std::cout << "Logfejl: " << ex.what() << std::endl;
    }

    return 0;
}
