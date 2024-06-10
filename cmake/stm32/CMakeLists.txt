# ##############################################################################
# My Cmake tempalte for STM
# ##############################################################################
cmake_minimum_required(VERSION 3.22)

set(PROJECT_NAME "Mine_STM32f103x")
set(PROJECT_FILES "FILES") # for all source files
set(TOOLCHAIN_FILE_NAME "My-arm-none-eabi.cmake")

# set project toolchain-file relative folder
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/${TOOLCHAIN_FILE_NAME})

# language support and key-file path setting
enable_language(C ASM CXX)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# <LANG>_EXTENSIONS alwasy default set to ON, it use to passing flags to
# compiler
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(${PROJECT_NAME})

# define build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

message("Build Type: " ${CMAKE_BUILD_TYPE})

# ##############################################################################
# include files and source files, definition by subdirectory CMakeLists.txt
# ##############################################################################

# Create an executable object type
add_executable(${CMAKE_PROJECT_NAME})
# Add STM32CubeMX generated sources
add_subdirectory(${PROJECT_FILES})

# Add sources to executable
target_sources(${CMAKE_PROJECT_NAME} PRIVATE # Add user sources file here
)

# Add include paths
target_include_directories(
  ${CMAKE_PROJECT_NAME} PRIVATE # Add user defined include paths
)

# Add project symbols (macros)
target_compile_definitions(
  ${CMAKE_PROJECT_NAME} PRIVATE # Add user defined symbols
)

# Link directories setup
target_link_directories(
  ${CMAKE_PROJECT_NAME} PRIVATE # Add user defined library search paths
)

# Add linked libraries
target_link_libraries(
  ${CMAKE_PROJECT_NAME} PRIVATE ${PROJECT_FILES} # Add user defined libraries
)

# ##############################################################################
# For customer target
# ##############################################################################

add_custom_target(
  bin ALL
  ${CMAKE_OBJCOPY} -O binary
  "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf"
  "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin"
  DEPENDS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf)

# size information, use toolchain "size" and "wc" tools
add_custom_target(
  size ALL
  ${CMAKE_SIZE} "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf"
  DEPENDS bin)

# ##############################################################################
# For customer command
# ##############################################################################

find_program(ST_INFO st-info) # find a program and store result in <VAR>
find_program(ST_FLASH st-flash)
find_program(ST_UTIL st-util)

if(ST_INFO AND ST_FLASH)
  set(FLASH_ADDR 0x08000000)

  # show info, then flash the .bin file
  add_custom_command(
    USES_TERMINAL
    OUTPUT flash-cmd
    COMMAND ${ST_INFO} --probe
    COMMAND ${ST_FLASH} --format binary write
            ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin ${FLASH_ADDR}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
    COMMENT "Running the flash......")

  add_custom_target(flash DEPENDS flash-cmd)

elseif(NOT ST_INFO)
  message(WARNING "`st-info` not found, flash will not be availabe!")
elseif(NOT ST_FLASH)
  message(WARNING "`st-flash` not found, flash will not be availabe!")
endif()


add_custom_command(
  USES_TERMINAL
  OUTPUT info-cmd
  COMMAND ${ST_INFO} --probe
  COMMENT "Printed All chip info")

add_custom_target(info DEPENDS info-cmd)
