#include <iostream>
#include <fstream>
#include <sqlite3.h>
#include "spdlog/spdlog.h"
#include "spdlog/sinks/basic_file_sink.h"

int main() {
    bool ok = true;

    // Start logger
    auto logger = spdlog::basic_logger_mt("file_logger", "systemlog.txt");
    logger->info("Healthcheck startet");

    // 1. Check systemlog file
    std::ifstream logfile("systemlog.txt");
    if (!logfile.is_open()) {
        logger->error("systemlog.txt findes ikke eller kan ikke åbnes");
        ok = false;
    }

    // 2. Check database
    sqlite3* db;
    if (sqlite3_open("sensordata.db", &db)) {
        logger->error("Kan ikke åbne sensordata.db");
        ok = false;
    } else {
        // 3. Check table 'measurements'
        const char* sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='measurements';";
        sqlite3_stmt* stmt;
        if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
            if (sqlite3_step(stmt) != SQLITE_ROW) {
                logger->error("Tabel 'measurements' findes ikke");
                ok = false;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }

    if (ok)
        logger->info("Healthcheck bestået: systemet er klar");

    spdlog::shutdown();
    return ok ? 0 : 1;
}
