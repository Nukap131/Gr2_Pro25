add_library(core
    mqtt_client.cpp
    db_handler.cpp
    sensor_handler.cpp
)
target_link_libraries(core sqlite3)
