cmake_minimum_required ( VERSION 3.22 )

project ( ${PROJECT_FILES} )
add_library ( ${PROJECT_FILES} INTERFACE )

set ( START_FILE "${CMAKE_CURRENT_LIST_DIR}/startup_stm32f103xb.s" )
get_filename_component ( START_FILE_ABSOLUTE ${START_FILE} ABSOLUTE )

enable_language ( C ASM )

target_compile_definitions (
  ${PROJECT_FILES} INTERFACE USE_HAL_DRIVER STM32F103xB
  $<$<CONFIG:Debug>:DEBUG> )

# ##############################################################################
# ALL project files
# ##############################################################################
file ( GLOB_RECURSE USER_APP_SRCS "../Core/App/*.c" )
set ( USER_DRIVER "../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c" )

set ( USER_APP_HEADERS "" )
file ( GLOB_RECURSE temp_h "../Core/App/*.h" )

foreach ( head ${temp_h} )
  get_filename_component ( dir ${head} DIRECTORY )
  list ( APPEND USER_APP_HEADERS ${dir} )
endforeach ( head ${temp_h} )

list ( REMOVE_DUPLICATES USER_APP_HEADERS )
message ( STATUS "User Custom include Directories: ${USER_APP_HEADERS}" )
target_include_directories (
  ${PROJECT_FILES}
  INTERFACE

  # TODO.
  # Add custom include path
  ${USER_APP_HEADERS} )

target_sources (
  ${PROJECT_FILES}
  INTERFACE

  # TODO.
  # Add custom source files
  ${START_FILE_ABSOLUTE}
  ${USER_APP_SRCS}
  ${USER_DRIVER} )

# for link library
target_link_directories ( ${CMAKE_PROJECT_NAME} INTERFACE )
target_link_libraries ( ${CMAKE_PROJECT_NAME} INTERFACE )

# Validate that STM32CubeMX code is compatible with C standard
if ( CMAKE_C_STANDARD LESS 11 )
  message ( ERROR "Generated code requires C11 or higher" )
endif ()
