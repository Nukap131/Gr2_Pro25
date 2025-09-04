#include <iostream>
#include <ctime>
#include <string>
#include <vector>

#include <nlohmann/json.hpp>
#include <mqtt/client.h>   // Paho MQTT C++ (v1.x) header

using json = nlohmann::json;

int main() {
    // ---- MQTT parametre ----
    const std::string broker   = "tcp://127.0.0.1:1883";
    const std::string clientId = "victor-json-pub";
    const std::string topic    = "spBv1.0/UCL-SEE-A/NDATA/TL/VentSensor";
    const int qos = 0;

    try {
        // ---- Byg JSON payload (pæn/“pretty”) ----
        std::time_t now = std::time(nullptr);
        json j;
        j["timestamp"] = static_cast<long long>(now * 1000);   // ms siden epoch

        // metrics-array
        j["metrics"] = json::array();

        // Temperatur
        j["metrics"].push_back({
            {"name", "temperature"},
            {"alias", 1},
            {"timestamp", static_cast<long long>(now * 1000)},
            {"dataType", "float"},
            {"value", 21.5}
        });

        // Fugt
        j["metrics"].push_back({
            {"name", "humidity"},
            {"alias", 2},
            {"timestamp", static_cast<long long>(now * 1000)},
            {"dataType", "float"},
            {"value", 42.0}
        });

        // Sekvens (valgfri—match tavlen)
        j["seq"] = 2;

        // ---- Print pænt som på tavlen ----
        std::string pretty = j.dump(4);   // 4 mellemrum indrykning
        std::cout << pretty << std::endl;

        // ---- MQTT publish ----
        mqtt::client cli(broker, clientId);
        mqtt::connect_options connopts;
        cli.connect(connopts);

        // Du kan publicere den “pæne” streng (fuldt gyldig JSON).
        mqtt::message_ptr msg = mqtt::make_message(topic, pretty);
        msg->set_qos(qos);
        cli.publish(msg);

        cli.disconnect();
        std::cout << "Published to " << topic << std::endl;
    }
    catch (const mqtt::exception& e) {
        std::cerr << "MQTT error: " << e.what() << std::endl;
        return 1;
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
