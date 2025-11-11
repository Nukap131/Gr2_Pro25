#include "mqtt_client.hpp"

MQTTClient::MQTTClient(const std::string& host, int port)
    : host_(host), port_(port), connected_(false) {}

bool MQTTClient::connect() {
    connected_ = true;
    return true;  // Simuler succes
}

bool MQTTClient::publish(const std::string& topic, const std::string& message) {
    if (!connected_) return false;
    return true;  // Simuler succes
}
