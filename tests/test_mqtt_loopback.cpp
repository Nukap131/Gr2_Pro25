#include <gtest/gtest.h>
#include <mqtt/async_client.h>
#include <chrono>
#include <thread>
#include <atomic>
#include <iostream>

using namespace std::chrono_literals;

TEST(MQTTLoopbackTest, PublishAndReceive) {
    const std::string SERVER{"tcp://localhost:1883"};
    const std::string TOPIC{"ventilation/loopback"};
    const std::string PAYLOAD{"hello from loopback test"};

    std::atomic<bool> received{false};
    std::string receivedMsg;

    // MQTT klient til subscribe
    mqtt::async_client subClient(SERVER, "gtest_sub");
    auto connOpts = mqtt::connect_options_builder().clean_session().finalize();

    // Callback når en besked modtages
    class callback : public virtual mqtt::callback {
        std::atomic<bool>& received;
        std::string& receivedMsg;
    public:
        callback(std::atomic<bool>& r, std::string& m) : received(r), receivedMsg(m) {}
        void message_arrived(mqtt::const_message_ptr msg) override {
            receivedMsg = msg->to_string();
            received = true;
        }
    };

    callback cb(received, receivedMsg);
    subClient.set_callback(cb);

    // Start subscriber
    subClient.connect(connOpts)->wait();
    subClient.subscribe(TOPIC, 1)->wait();

    // MQTT klient til publish
    mqtt::async_client pubClient(SERVER, "gtest_pub");
    pubClient.connect(connOpts)->wait();
    pubClient.publish(TOPIC, PAYLOAD.data(), PAYLOAD.size(), 1, false)->wait();

    // Vent lidt for at modtage beskeden
    for (int i = 0; i < 20 && !received; ++i)
        std::this_thread::sleep_for(100ms);

    // Ryd op
    pubClient.disconnect()->wait();
    subClient.disconnect()->wait();

    EXPECT_TRUE(received);
    EXPECT_EQ(receivedMsg, PAYLOAD);
}
