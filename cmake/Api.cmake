# Represent for `message(STATUS msg)`
macro ( info _msg )
    message ( STATUS "@@@@@@@@@@ ${_msg} @@@@@@@@@@" )
endmacro ()

# Generate more debug information for given target
# Usage: more_debug_info(target_name)
function ( more_debug_info _target_name )
    if ( NOT TARGET ${_target_name} )
        message ( FATAL_ERROR "@@@@@@@@@@ ${_target_name} Wrong @@@@@@@@@" )
    endif ()

    set ( debug_ARCHIVES ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${_target_name}.dir )

    # Save intermediate files (.i .s .o)
    target_compile_options ( ${_target_name} PRIVATE -save-temps=obj )

    # Generate assembly listing and map files
    target_compile_options ( ${_target_name} PRIVATE
        -fverbose-asm
        -Wa,-ahlms=${debug_ARCHIVES}/${_target_name}.lst
    )

    # Generate linker map file
    target_link_options ( ${_target_name} PRIVATE
        -Wl,-Map=${debug_ARCHIVES}/${_target_name}.map
    )

    # Generate disassembler files
    add_custom_command (
        TARGET ${_target_name} POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -S --source-comment="[@@@SOURCES@@@]"
        $<TARGET_FILE:${_target_name}> > ${debug_ARCHIVES}/${_target_name}.disasm
        COMMENT "@@@@@@@@@ Generating Disassembler Information @@@@@@@@@@"
        VERBATIM
    )
endfunction ( more_debug_info _target_name )

# Get current project generated all executable files
# Usage: get_allexecutables(<output_var>)
function ( get_all_executables _output_var )
    get_property ( _targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS )
    set ( _executables )

    foreach ( target IN LISTS ${_targets} )
        get_target_property ( _type ${target} TYPE )

        if ( _type STREQUAL "EXECUTABLE" )
            list ( APPEND _executables ${target} )
        endif ()
    endforeach ()

    # Result is a list
    set ( ${_output_var} ${_executables} PARENT_SCOPE )
endfunction ()

# Build executables from parallel name and source lists
# Usage: build_executables(<name_list> <source_list> [INCLUDE_DIRS dirs...] [LINK_LIBS libs...])
function ( build_executables _name_list _src_list )
    set ( _options )
    set ( _one_value_args )
    set ( _multi_value_args INCLUDE_DIRS LINK_LIBS COMPILE_OPTIONS )
    cmake_parse_arguments ( ARG "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN} )

    list ( LENGTH _name_list _name_len )
    list ( LENGTH _src_list _src_len )

    if ( NOT _name_len EQUAL _src_len )
        message ( FATAL_ERROR "build_executables: name list length (${_name_len}) != source list len (${_src_len})" )
    endif ()

    # Iterator to use add_executable()
    math ( EXPR _last_index "${_name_len} - 1" )

    foreach ( _i RANGE ${_last_index} )
        list ( GET _name_list ${_i} _name )
        list ( GET _src_list ${_i} _src )

        add_executable ( ${_name} ${_src} )

        if ( ARG_INCLUDE_DIRS )
            target_link_directories ( ${_name} PRIVATE ${ARG_INCLUDE_DIRS} )
        endif ()

        if ( ARG_LINK_LIBS )
            target_link_libraries ((${_name}) PRIVATE ${ARG_LINK_LIBS} )
        endif ()

        if ( ARG_COMPILE_OPTIONS )
            target_compile_options ( ${_name} PRIVATE ${ARG_COMPILE_OPTIONS} )
        endif ()

        info ( "Building Executable: ${_src} ---> ${_name}" )
    endforeach ()
endfunction ()

# Generate separate executables for each source file under a directory
# Usage: generate_executables(<dir> [RECURSIVE] [INCLUDE_DIRS dirs...] [LINK_LIBS libs...])
function ( generate_executables _dir )
    if ( NOT IS_DIRECTORY "${_dir}" )
        message ( FATAL_ERROR "@@@@@@@@@ ${_dir} is NOT A DIRECTORY @@@@@@@@" )
    endif ()

    # Parse arguments
    set ( _options RECURSIVE )
    set ( _one_value_args )
    set ( _multi_value_args INCLUDE_DIRS LINK_LIBS COMPILE_OPTIONS )
    cmake_parse_arguments ( ARG "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN} )

    if ( ARG_RECURSIVE )
        file ( GLOB_RECURSE _sources "${_dir}/*.c" "${_dir}/*.cpp" )
    else ()
        file ( GLOB _sources "${_dir}/*.c" "${_dir}/*.cpp" )
    endif ()

    if ( NOT _sources )
        message ( WARNING "generate_executables: No source files found in '${_dir}'" )
        return ()
    endif ()

    # Get all existed executables for duplicate detection
    get_all_executables ( _existing_targets )
    set ( _names )
    set ( _valid_sources )

    foreach ( _src IN LISTS _sources )
        get_filename_component ( _name "${_src}" NAME_WE )

        if ( _name IN_LIST _existing_targets )
            message ( WARNING "generate_executables: Skipping '${_name}', target already exist." )
            continue ()
        endif ()

        list ( APPEND _names ${_name} )
        list ( APPEND _valid_sources ${_src} )
    endforeach ( _src IN LISTS _sources )

    if ( NOT _names )
        return ()
    endif ()

    # Forward compile arguments
    set ( _forward_args )

    if ( ARG_INCLUDE_DIRS )
        list ( APPEND _forward_args INCLUDE_DIRS ${ARG_INCLUDE_DIRS} )
    endif ()

    if ( ARG_LINK_LIBS )
        list ( APPEND _forward_args LINK_LIBS ${ARG_LINK_LIBS} )
    endif ()

    if ( ARG_COMPILE_OPTIONS )
        list ( APPEND _forward_args COMPILE_OPTIONS ${ARG_COMPILE_OPTIONS} )
    endif ()

    build_executables ( "${_names}" "${_valid_sources}" ${_forward_args} )
    list ( LENGTH _names _count )
    info ( "generate_executables: Created ${_count} targets from '${_dir}'" )
endfunction ( generate_executables _dir )
