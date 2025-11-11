#include <gtest/gtest.h>
#include "../include/mqtt_client.hpp"

TEST(MQTTTest, ConnectToBroker) {
    MQTTClient client("localhost", 1883);
    EXPECT_TRUE(client.connect());
}

TEST(MQTTTest, PublishMessage) {
    MQTTClient client("localhost", 1883);
    client.connect();
    EXPECT_TRUE(client.publish("ventilation/test", "hello world"));
}

// Main entry point for GTest
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
