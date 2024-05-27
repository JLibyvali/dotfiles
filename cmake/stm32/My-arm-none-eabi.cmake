# My Toolchain file main base
# https://github.com/jobroe/cmake-arm-embedded/blob/master/toolchain-arm-none-eabi.cmake
# and STM32CubeMX

# Append current directory to CMAKE_MODULE_PATH for making device specific cmake
# modules visible
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Target definition
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

# ---------------------------------------------------------------------------------------
# Set toolchain paths
# ---------------------------------------------------------------------------------------

set(LD_SCRIPT_DIR "${CMAKE_CURRENT_LIST_DIR}/STM32F103C8Tx_FLASH.ld")
get_filename_component(LD_SCRIPT_DIR_ABSOLUTE ${LD_SCRIPT_DIR} ABSOLUTE)

set(TOOLCHAIN_DIR "/home/jlibyvali/TOOLS/arm-none-eabi-GNUtoolchain")
set(TOOLCHAIN_PREFIX "arm-none-eabi")

# function(CHECK TOOL OUTPUT_VAR)

#   execute_process(
#     COMMAND ${TOOL} --version
#     RESULT_VARIABLE RESULT
#     OUTPUT_VARIABLE OUTPUT
#     ERROR_VARIABLE ERROR_OUTPUT
#     OUTPUT_STRIP_TRAILING_WHITESPACE)

#   if(${RESULT} EQUAL 0)
#     set(${OUTPUT_VAR}
#         ${OUTPUT}
#         PARENT_SCOPE)
#  else()
#     message(FATAL_ERROR "Failed to run ${TOOL} --version: ${ERROR_OUTPUT}")
#   endif()

# endfunction()

set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_DIR}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}/lib)

# MCU flags and system extension
set(CPU_TYPE "cortex-m3")

if(WIN32)
  set(TOOLCHAIN_EXT ".exe")
else()
  set(TOOLCHAIN_EXT "")
endif()

# ---------------------------------------------------------------------------------------
# Set compilers
# ---------------------------------------------------------------------------------------
# use cache internal to keep toolchain stable
set(CMAKE_C_COMPILER
    ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-gcc${TOOLCHAIN_EXT}
    CACHE INTERNAL "C Compiler")
set(CMAKE_CXX_COMPILER
    ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-g++${TOOLCHAIN_EXT}
    CACHE INTERNAL "C++ Compiler")
set(CMAKE_ASM_COMPILER
    ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-gcc${TOOLCHAIN_EXT}
    CACHE INTERNAL "ASM Compiler")
set(CMAKE_LINKER
    ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-g++${TOOLCHAIN_EXT}
    CACHE INTERNAL "Linker")
set(CMAKE_OBJCOPY
    ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-objcopy${TOOLCHAIN_EXT}
    CACHE INTERNAL "Objcopy")
set(CMAKE_SIZE
    ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-size${TOOLCHAIN_EXT}
    CACHE INTERNAL "size")

# add addtional path  for cmake: find_program, find_library, find_xx it's useful
# for crossing compile, "NERVER":find_xxx() nerver use the define path, just
# find in system path "ONLY": find_xxx() only use the define path
set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}
                         ${CMAKE_PREFIX_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# ##############################################################################
# Check Status
# ##############################################################################
# check(${CMAKE_C_COMPILER} C_COMPILER_VERSION)
# check(${CMAKE_CXX_COMPILER} CXX_COMPILER_VERSION)
# message(STATUS "C Compiler version:\n${C_COMPILER_VERSION}")
# message(STATUS "CXX Compiler version:\n${CXX_COMPILER_VERSION}")

set(CMAKE_EXECUTABLE_SUFFIX_ASM ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_C ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_CXX ".elf")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ---------------------------------------------------------------------------------------
# Set compiler/linker flags
# ---------------------------------------------------------------------------------------

# Object build options -O0                   No optimizations, reduce
# compilation time and make debugging produce the expected results. -mthumb
# Generat thumb instructions. -fno-builtin          Do not use built-in
# functions provided by GCC. -Wall                 Print only standard warnings,
# for all use Wextra -ffunction-sections   Place each function item into its own
# section in the output file. -fdata-sections       Place each data item into
# its own section in the output file. -fomit-frame-pointer  Omit the frame
# pointer in functions that don’t need one. -mabi=aapcs           Defines enums
# to be a variable sized type. -ggdb3                Produce debugging
# information in the operating system’s native format.
#
# https://gcc.gnu.org/onlinedocs/gcc-6.1.0/gcc/ARM-Options.html I build for
# Cortex-M0, so I use -mtune=cortex-m0 -mcpu=cortex-m0
set(OBJECT_GEN_FLAGS
    "-O0 -mthumb -fno-builtin -Wall -ffunction-sections -fdata-sections -fomit-frame-pointer -ggdb3 -mabi=aapcs -mtune=${CPU_TYPE} -mcpu=${CPU_TYPE}"
)

set(CMAKE_C_FLAGS
    "${OBJECT_GEN_FLAGS}"
    CACHE INTERNAL "C Compiler options")
set(CMAKE_CXX_FLAGS
    "${OBJECT_GEN_FLAGS}"
    CACHE INTERNAL "C++ Compiler options")
set(CMAKE_ASM_FLAGS
    "${OBJECT_GEN_FLAGS} -x assembler-with-cpp "
    CACHE INTERNAL "ASM Compiler options")

# -Wl,--gc-sections     Perform the dead code elimination. --specs=nano.specs
# Link with newlib-nano. --specs=nosys.specs   No syscalls, provide empty
# implementations for the POSIX system calls. -n Turn off page alignment of
# sections, and disable linking against shared libraries.  If the output format
# supports Unix style magic numbers, mark the output as "NMAGIC".
# https://stackoverflow.com/questions/66721383/why-does-arm-none-eabi-ld-align-program-headers-to-64kib-when-linking-how-do-i
#
# linker script is set here to link symbols (--just-symbols) you just need to
# append the symbols file to linker
set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections  --specs=nosys.specs --specs=nano.specs -mabi=aapcs -Wl,-Map=\"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.map\" -T \"${LD_SCRIPT_DIR}\" -mcpu=${CPU_TYPE} -mthumb -n"
    CACHE INTERNAL "Linker options")

# ---------------------------------------------------------------------------------------
# Set debug/release build configuration Options
# ---------------------------------------------------------------------------------------

# Options for DEBUG build -Og   Enables optimizations that do not interfere with
# debugging. -g    Produce debugging information in the operating system’s
# native format.
set(CMAKE_C_FLAGS_DEBUG
    "-Og -g"
    CACHE INTERNAL "C Compiler options for debug build type")
set(CMAKE_CXX_FLAGS_DEBUG
    "-Og -g"
    CACHE INTERNAL "C++ Compiler options for debug build type")
set(CMAKE_ASM_FLAGS_DEBUG
    "-g"
    CACHE INTERNAL "ASM Compiler options for debug build type")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG
    ""
    CACHE INTERNAL "Linker options for debug build type")

# Options for RELEASE build -Os   Optimize for size. -Os enables all -O2
# optimizations. -flto Runs the standard link-time optimizer.
set(CMAKE_C_FLAGS_RELEASE
    "-Os -flto"
    CACHE INTERNAL "C Compiler options for release build type")
set(CMAKE_CXX_FLAGS_RELEASE
    "-Os -flto"
    CACHE INTERNAL "C++ Compiler options for release build type")
set(CMAKE_ASM_FLAGS_RELEASE
    ""
    CACHE INTERNAL "ASM Compiler options for release build type")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE
    "-flto"
    CACHE INTERNAL "Linker options for release build type")
