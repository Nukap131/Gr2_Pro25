enable_testing()
find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS} ../include)

add_executable(runTests
    test_mqtt.cpp
    test_mqtt_loopback.cpp
    test_db.cpp
    test_sensor.cpp
)


target_link_libraries(runTests
    core
    ${GTEST_LIBRARIES}
    pthread
    paho-mqttpp3
    paho-mqtt3as
)


# Sørg for at CTest faktisk kører programmet
add_test(NAME RunAllTests COMMAND runTests)
