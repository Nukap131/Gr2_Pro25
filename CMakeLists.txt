
# ---- spdlog (submodule) global config ----
# Header-only = ingen linking nødvendig
add_definitions(-DSPDLOG_HEADER_ONLY)
include_directories(${CMAKE_SOURCE_DIR}/external/spdlog/include)
# -----------------------------------------
