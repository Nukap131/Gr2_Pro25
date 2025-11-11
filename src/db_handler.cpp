#include "db_handler.hpp"
#include <iostream>

Database::Database(const std::string& path) : db_path_(path) {
    if (sqlite3_open(db_path_.c_str(), &db_) != SQLITE_OK) {
        std::cerr << "❌ Kunne ikke åbne database: " << sqlite3_errmsg(db_) << std::endl;
        db_ = nullptr;
    } else {
        // Opret tabel hvis den ikke findes
        const char* createTable =
            "CREATE TABLE IF NOT EXISTS measurements("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "sensor TEXT,"
            "value REAL,"
            "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP);";
        sqlite3_exec(db_, createTable, nullptr, nullptr, nullptr);
    }
}

Database::~Database() {
    if (db_) sqlite3_close(db_);
}

bool Database::insertRecord(const std::string& sensor, double value) {
    if (!db_) return false;
    std::string sql = "INSERT INTO measurements(device_id, value) VALUES('" + sensor + "', " + std::to_string(value) + ");";

    char* errMsg = nullptr;
    if (sqlite3_exec(db_, sql.c_str(), nullptr, nullptr, &errMsg) != SQLITE_OK) {
        std::cerr << "❌ Fejl ved indsættelse: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

double Database::getLastValue(const std::string& sensor) {
    if (!db_) return -9999;
    std::string sql = "SELECT value FROM measurements WHERE device_id='" + sensor + "' ORDER BY id DESC LIMIT 1;";

    sqlite3_stmt* stmt = nullptr;
    double result = -9999;
    if (sqlite3_prepare_v2(db_, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            result = sqlite3_column_double(stmt, 0);
        }
    }
    sqlite3_finalize(stmt);
    return result;
}
