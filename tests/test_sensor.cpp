#include <gtest/gtest.h>
#include "../include/sensor_handler.hpp"

TEST(SensorTest, ReadsValidRange) {
    SensorHandler s;
    double value = s.readTemperature();
    EXPECT_GE(value, -40);
    EXPECT_LE(value, 85);
}
