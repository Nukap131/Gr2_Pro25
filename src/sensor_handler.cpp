#include "sensor_handler.hpp"
#include <cstdlib>

SensorHandler::SensorHandler() {}

double SensorHandler::readTemperature() {
    // Simuler tilfældig temperatur i rimeligt område
    return 20.0 + (std::rand() % 1000 - 500) / 100.0;
}
