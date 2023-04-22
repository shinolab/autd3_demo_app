cmake_minimum_required(VERSION 3.21)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt. ")
endif()

project(autd3-demo-app-server)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(main main.cpp)

set(BUILD_GAIN_HOLO OFF)
set(DISABLE_EXAMPLES ON)
add_subdirectory(${PROJECT_SOURCE_DIR}/3rdparty/autd3)

target_link_libraries(main PRIVATE autd3 link_soem)
target_link_libraries(main PRIVATE rt)
target_include_directories(main PRIVATE ${PROJECT_SOURCE_DIR}/3rdparty/spdlog/include)
