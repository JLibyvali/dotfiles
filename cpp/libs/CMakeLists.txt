cmake_minimum_required ( VERSION 3.22 )
project ( libs )

set ( CMAKE_EXPORT_COMPILE_COMMANDS ON )

set ( CMAKE_C_FLAGS_DEBUG "-g3 -ggdb3 -O0 " )
set ( CMAKE_CXX_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG} )

find_program ( CCACHE_FOUND ccache )

if ( CCACHE_FOUND )
    set(CMAKE_C_COMPILER_LAUNCHER ccache)
    set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
elseif()
    message(FATAL_ERROR "Not found ccache")
endif ()

# benchmark
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/benchmark )

# brpc
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/brpc )

# concurrentqueue INTERFACE library
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/concurrentqueue )

# cppzmq
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/cppzmq )

# libuv, libevent
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/libuv )
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/libevent )

# oneTBB
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/oneTBB )

# protobuf
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/protobuf )

# taskflow
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/taskflow )

# tinyprocess
add_subdirectory ( ${CMAKE_SOURCE_DIR}/3rdpart/tiny-process-library )


