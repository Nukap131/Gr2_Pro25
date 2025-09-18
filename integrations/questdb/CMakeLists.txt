cmake_minimum_required(VERSION 3.10)
project(questdb_test LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Headers i include/
include_directories(${CMAKE_SOURCE_DIR}/include)

# Biblioteker i build/
link_directories(${CMAKE_SOURCE_DIR}/build)

# Byg vores testprogram
add_executable(questdb_test questdb_test.cpp)

# Link mod questdb client lib
target_link_libraries(questdb_test questdb_client)
