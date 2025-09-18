/**
 * @file questdb_test.cpp
 * @brief Eksempel: send en række til QuestDB via C++ client (ILP/HTTP).
 * @details Forbinder til QuestDB containeren på 127.0.0.1:9100 og indsætter
 * en test-række i tabellen `trades` med symbol, side, pris og amount.
 * Bygning: cmake .. && make (se CMakeLists.txt i samme mappe).
 */



#include <questdb/ingress/line_sender.hpp>
#include <iostream>

/**
 * @brief Program entrypoint der sender en enkelt række til `trades`.
 * @return 0 ved succes (kaster exceptions ved fejl).
 */

int main() {
    try {
        questdb::ingress::line_sender sender =
            questdb::ingress::line_sender::from_conf("http::addr=127.0.0.1:9100;");

        questdb::ingress::line_sender_buffer buffer(
            questdb::ingress::protocol_version::v2,
            1024,
            8192
        );

        buffer
            .table("trades")
            .symbol("symbol", "BTC-USD")
            .symbol("side", "buy")
            .column("price", 27123.45)
            .column("amount", 0.5)
            .at(questdb::ingress::timestamp_nanos::now());

        sender.flush(buffer);
        sender.close();

        std::cout << "✅ Data sendt til QuestDB (questdb2)" << std::endl;
    } catch (const std::exception &ex) {
        std::cerr << "Fejl: " << ex.what() << std::endl;
    }
}


