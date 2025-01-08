# ------------------------------------------------------------------------------------------------------------------------------------------------
# Language and General
# ------------------------------------------------------------------------------------------------------------------------------------------------
enable_language ( C CXX ASM )
set ( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set ( CMAKE_C_STANDARD 11 )
set ( CMAKE_C_STANDARD_REQUIRED ON )
set ( CMAKE_C_EXTENSIONS OFF )
set ( CMAKE_CXX_STANDARD 20 )
set ( CMAKE_CXX_STANDARD_REQUIRED ON )
set ( CMAKE_CXX_EXTENSIONS OFF )

if ( CMAKE_EXPORT_COMPILE_COMMANDS )
    # https://gitlab.kitware.com/cmake/cmake/-/issues/20912#note_793338:~:text=Thank%20you%2C%20that%20helps!%20Now%20I%20can%20simply%20use%20it%3A
    # For llvm/clang tools to find the stdc++ library headers.c
    set ( CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES} )
endif ()

# ## ToolChain Path
set ( TOOLCHAIN_PREFIX )

if ( NOT DEFINED TOOLCHAIN_PATH )
    if ( CMAKE_HOST_SYSTEM_NAME STREQUAL Linux )
        set ( TOOLCHAIN_PATH "/usr" )
    elseif ( CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin )
        set ( TOOLCHAIN_PATH "/usr/local" )
    elseif ( CMAKE_HOST_SYSTEM_NAME STREQUAL Windows )
        message ( STATUS "Please specify the TOOLCHAIN_PATH !\n For example: -DTOOLCHAIN_PATH=\"C:/Program Files/GNU Tools ARM Embedded\" " )
    else ()
        set ( TOOLCHAIN_PATH "/usr" )
        message ( STATUS "No TOOLCHAIN_PATH specified, using default: " ${TOOLCHAIN_PATH} )
    endif ()
endif ()

set ( TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PATH}/bin )
set ( TOOLCHAIN_INC_DIR ${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}/include )
set ( TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}/lib )

# ## ToolChain file extension.
if ( WIN32 )
    set ( TOOLCHAIN_EXT ".exe" )
else ()
    set ( TOOLCHAIN_EXT "" )
endif ()

# ## Perform compiler test with static library
set ( CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY )

# ------------------------------------------------------------------------------------------------------------------------------------------------
# Compiler/linker
# ------------------------------------------------------------------------------------------------------------------------------------------------
# ######################### architecture flags
# -m64/32                   "The -m64 option sets int to 32 bits and long and pointer types to 64 bits, and generates code for the x86-64 architecture. "
# -march/-mcpu/-mtune       "-march=cpu-type allows GCC to generate code that may not run at all on processors other than the one indicated. "
# ######################### arm architecture flags
# -fno-builtin              "Do not use built-in functions provided by GCC.""
# -mabi=                    "Generate code for the specified ABI. Permissible values are: ‘apcs-gnu’, ‘atpcs’, ‘aapcs’, ‘aapcs-linux’ and ‘iwmmxt’."
# -mthumb                   "Thumb instructions setc"
# ######################### debug flags
# -g/ggdb <level>           "Level 3 includes extra information, such as all the macro definitions present in the program. Some debuggers support macro expansion when you use -g3."
# -O0                       "No optmization, faster compilation time, better for debugging builds."
# -Og                       "It is a better choice than -O0 for producing debuggable code because some compiler passes that collect debug information are disabled at -O0."
# -Wall                     "Turns on lots of compiler warning flags,"
# -fcf-protection           "nable code instrumentation of control-flow transfers to increase program security by checking that target addresses of control-flow transfer instructions (such as indirect function call, function return, indirect jump) are valid"
# -fpic                     "Generate position-independent code (PIC) suitable for use in a shared library, if supported for the target machine"
# -fpie                     "These options are similar to -fpic and -fPIC, but the generated position-independent code can be only linked into executables"
# -fexceptions              "Enable exception handling. Generates extra code needed to propagate exceptions. Recommed for multithreads"
# -fstack-protector-strong  "Like -fstack-protector but includes additional functions to be protected — those that have local array definitions, or have references to local frame addresses. "
# -fstack-clash-protection  "Generate code to prevent stack clash style attacks. When this option is enabled, the compiler will only allocate one page of stack space at a time and each page is accessed immediately after allocation. "
# -fstack-usage             "list all function stack usage"
# -funroll-all-loops        "Unroll all loops, even if their number of iterations is uncertain when the loop is entered. This usually makes programs run more slowly."
# ######################### performance tools flags
# -pg                       "for "gprof" generate data."
# -fasynchronous-unwind-tables " is required for many debugging and performance tools to work on most architectures"
# -fsanitize=address        "Enable AddressSanitizer, a fast memory error detector. Memory access instructions are instrumented to detect out-of-bounds and use-after-free bugs."
# -fsanitize=thread/leak/undefined "Sanitizer library"
# ######################### GCC helper , check flags is correct.
# -grecord-gcc-switches     "captures compiler flags, which can be useful to determine whether the intended compiler flags are used throughout the build."
set ( CPU_TYPE "native" )
set ( FLAG_SAFER "-fcf-protection -fexceptions -fstack-protector-strong -fstack-clash-protection " )
set ( FLAG_OBJGEN "-O0 -m64 -march=${CPU_TYPE} -mcpu=${CPU_TYPE} -mtune=${CPU_TYPE} -Wall -ffunction-sections -fdata-sections -fstack-usage -funroll-all-loops" )
set ( FLAG_ARM "-O0 -march=${CPU_TYPE} -mcpu=${CPU_TYPE} -mtune=${CPU_TYPE} -Wall -fno-builtin -mthumb -ffunction-sections -fdata-sections -mabi=aapcs" )

set ( CMAKE_C_FLAGS "${FLAG_SAFER} ${FLAG_OBJGEN}" CACHE INTERNAL "C Compiler option flags" )
set ( CMAKE_CXX_FLAGS "${FLAG_SAFER} ${FLAG_OBJGEN}" CACHE INTERNAL "C++ Compiler option flags" )
set ( CMAKE_ASM_FLAGS "${FLAG_SAFER} ${FLAG_OBJGEN} -x assembler-with-cpp" CACHE INTERNAL "ASM Compiler option flags" )

# ######################### linker
# -Wl,--gc-sections         "the linker can perform the dead code elimination."
# -Wl,-Map                      "Create a map file for debug" -fuse-ld "Use the gold linker instead of the default linker."
# -pie                      "Produce a dynamically linked position independent executable on targets that support it."
# -shared                   "Produce a shared object which can then be linked with other objects to form an executable."
# -flto                     "hen the object files are linked together, all the function bodies are read from these ELF sections and instantiated as if they had been part of the same translation unit."
# -fuse-linker-plugin       "This option enables the extraction of object files with GIMPLE bytecode out of library archives. This improves the quality of optimization by exposing more code to the link-time optimizer."
# -fuse-ld=bfd/lld/gold     "Set linker instead of default linker. "
# ######################### arm linker flags
# -n                        "Set the text segment to be read only, and mark the output as NMAGIC if possible."
# Turn off page alignment of sections, and disable linking
# against shared libraries.  If the output format supports Unix
# style magic numbers, mark the output as "NMAGIC".
# https://stackoverflow.com/questions/66721383/why-does-arm-none-eabi-ld-align-program-headers-to-64kib-when-linking-how-do-i
#
# --specs=nano.specs    Link with newlib-nano.
# --specs=nosys.specs   No syscalls, provide empty implementations for the POSIX system calls.
# -T                    "Use script as the linker script"
set ( CMAKE_EXE_LINKER_FLAGS "-fuse-ld=gold -fuse-linker-plugin -Wl,-Map=\"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.map\"" CACHE INTERNAL "Linker options flags" )

# ------------------------------------------------------------------------------------------------------------------------------------------------
# C++ Template Debug flags
# ------------------------------------------------------------------------------------------------------------------------------------------------
# -fno-elide-type           "Turns off elision in template type printing"
# -fdiagnostics-show-template-tree "Template type diffing prints a text tree from single line"
# -ftemplate-backtrace-limit "The default is 10, and the limit can be disabled with -ftemplate-backtrace-limit=0."
# -fno-module-ts,-fno-deps-format "For clang-tidy when used gcc compile"
set ( FLAG_TEMPLATE_DEBUG "-fno-elide-type -fdiagnostics-show-template-tree" )

set ( CMAKE_C_FLAGS_DEBUG "-Og -g3 -ggdb3" CACHE INTERNAL "C Compiler options for debug build type" )
set ( CMAKE_CXX_FLAGS_DEBUG "-Og -g3 -ggdb3" CACHE INTERNAL "C++ Compiler options for debug build type" )
set ( CMAKE_ASM_FLAGS_DEBUG "-g3 -ggdb3" CACHE INTERNAL "ASM Compiler options for debug build type" )
set ( CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Linker options for debug build type" )

set ( CMAKE_C_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "C Compiler options for release build type" )
set ( CMAKE_CXX_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "C++ Compiler options for release build type" )
set ( CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "ASM Compiler options for release build type" )
set ( CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto" CACHE INTERNAL "Linker options for release build type" )

# ---------------------------------------------------------------------------------------
# Set compilers
# ---------------------------------------------------------------------------------------
set ( CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "C Compiler" )
set ( CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-g++${TOOLCHAIN_EXT} CACHE INTERNAL "C++ Compiler" )
set ( CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN_PREFIX}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "ASM Compiler" )

if ( TOOLCHAIN_PREFIX )
    set ( CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PATH}/${${TOOLCHAIN_PREFIX}} ${CMAKE_PREFIX_PATH} )
    set ( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
    set ( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
    set ( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
    set ( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )
endif ()