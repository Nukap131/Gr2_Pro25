/**
 * @file questdb_test.cpp
 * @brief Testklient til QuestDB i C++.
 *
 * Dette eksempel demonstrerer integration mellem C++ og QuestDB.
 * Programmet indsætter en række data i tabellen `sensor_data`.
 */

#include <questdb/ingress/line_sender.hpp>
#include <iostream>
#include <stdexcept>

/**
 * @brief Entry point der indsætter en række i QuestDB.
 *
 * Denne funktion opretter en forbindelse til QuestDB (127.0.0.1:9009)
 * og indsætter en række med device, value og timestamp.
 *
 * @return 0 ved succes, 1 ved fejl.
 */
int main() {
    try {
        questdb::ingress::line_sender sender{"127.0.0.1", 9009};
        sender.table("sensor_data")
              .column("device", "esp32")
              .column("value", 42.5)
              .at_now();
        sender.flush();

        std::cout << "✅ Række indsat i QuestDB!" << std::endl;
    } catch (const std::exception &e) {
        std::cerr << "❌ Fejl: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
