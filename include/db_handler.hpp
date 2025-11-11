#pragma once
#include <string>
#include <sqlite3.h>

class Database {
public:
    explicit Database(const std::string& path);
    ~Database();

    bool insertRecord(const std::string& sensor, double value);
    double getLastValue(const std::string& sensor);

private:
    sqlite3* db_ = nullptr;
    std::string db_path_;
};
