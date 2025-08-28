#pragma once
#if __has_include(<spdlog/spdlog.h>)
  #include <spdlog/spdlog.h>
  inline void init_logging() {
    spdlog::set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%^%l%$] %v");
    spdlog::set_level(spdlog::level::info);
    spdlog::info("Logging initialized");
  }
  inline void log_info(const std::string& s){ spdlog::info(s); }
  inline void log_warn(const std::string& s){ spdlog::warn(s); }
  inline void log_error(const std::string& s){ spdlog::error(s); }
#else
  inline void init_logging() {}
  inline void log_info(const std::string&){ }
  inline void log_warn(const std::string&){ }
  inline void log_error(const std::string&){ }
#endif
