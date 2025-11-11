#include <gtest/gtest.h>
#include "../include/db_handler.hpp"
#include <filesystem>

TEST(DatabaseTest, InsertAndRetrieveRecord) {
    std::string dbPath = "/home/victor/tempprojekt/sensordata.db";

    ASSERT_TRUE(std::filesystem::exists(dbPath));

    Database db(dbPath);

    double testValue = 21.5;
    EXPECT_TRUE(db.insertRecord("TEMP", testValue));

    double lastVal = db.getLastValue("TEMP");
    EXPECT_NEAR(lastVal, testValue, 0.0001);
}
