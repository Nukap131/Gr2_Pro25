#pragma once
#include <string>

class MQTTClient {
public:
    MQTTClient(const std::string& host, int port);
    bool connect();
    bool publish(const std::string& topic, const std::string& message);

private:
    std::string host_;
    int port_;
    bool connected_;
};
