# ####################################################################################################
# Add Test related functions
# ####################################################################################################

# Get Project current all executable object created via `add_executable()`.
# @Usage: get_allexecutables( results_list )
# @arg: _return_list the list to store all results.
macro ( get_allexecutables _return_list )
    get_property ( _targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS )
    set ( _executables )

    foreach ( target ${_targets} )
        get_target_property ( type ${target} TYPE )

        if ( type STREQUAL "EXECUTABLE" )
            list ( APPEND _executables ${target} )
        endif ()
    endforeach ()

    set ( ${_return_list} ${_executables} )
endmacro ()

# Build a series executables with given lists.
# @Usage: build_executables( _name_list  _src_list)
# @arg: _name_list A CMake list variable that will used as the name of `add_executable()`
# @arg: _src_list Executable source file list
macro ( build_executables _name_list _src_list )
    list ( LENGTH ${_name_list} len )

    # Iterator to use add_executable()
    math ( EXPR j "${len}-1" )

    foreach ( i RANGE ${j} )
        list ( GET ${_name_list} ${i} _name )
        list ( GET ${_src_list} ${i} _srcs )

        info ( "BUILD ${_name} <--  ${_srcs}" )
        add_executable ( ${_name} ${_srcs} )
    endforeach ()
endmacro ()

# Generate Separate Executable from C/C++ single source files, the backward is that you cannot link libraries for these executables.
# Usage: generate_executables(_dir [RECURSIVE])
# @arg: _dir Must be a Absolute PATH
function ( generate_executables _dir )
    if ( NOT IS_DIRECTORY "${_dir}" )
        message ( FATAL_ERROR "@@@@@@@@@ ${_dir} is NOT A DIRECTORY @@@@@@@@" )
    endif ()

    set ( options RECURSIVE )
    cmake_parse_arguments ( _arg "${options}" "" "" )

    # Get source files
    set ( _Csources )
    set ( _CPPsources )

    if ( _arg_RECURSIVE )
        file ( GLOB_RECURSE _Csources "${_dir}/*.c" )
        file ( GLOB_RECURSE _CPPsources "${_dir}/*.cpp" )
    endif ()

    file ( GLOB _Csources "${_dir}/*.c" )
    file ( GLOB _CPPsources "${_dir}/*.cpp" )

    # Get all executables list to check duplicated target name
    get_allexecutables ( ALL_EXECUTABLES )
    set ( C_names )
    set ( CPP_names )

    foreach ( _file IN ZIP_LISTS _Csources _CPPsources )
        get_filename_component ( cname "${_file_0}" NAME_WE NAME_WLE )
        get_filename_component ( cppname "${_file_1}" NAME_WE NAME_WLE )

        list ( APPEND C_names ${cname} )
        list ( APPEND CPP_names ${cppname} )
    endforeach ()

    foreach ( _name IN ZIP_LISTS C_names CPP_names )
        set ( _name_0 -2 )
        set ( _name_1 -2 )
        list ( FIND ALL_EXECUTABLES ${_name_0} cindex )
        list ( FIND ALL_EXECUTABLES ${_name_1} cppindex )

        if ((NOT ${cindex} EQUAL -1) OR(NOT ${cppindex} EQUAL -1) )
            set ( msg "@@@@@@@ Input target name is duplicated: index ${cindex} in C targets, index ${cppindex} in CPP Targets @@@@@" )
            message ( FATAL_ERROR ${msg} )
        endif ()
    endforeach ()

    if ( NOT "${C_names}" STREQUAL "" )
        build_executables ( C_names _Csources )
    endif ()

    if ( NOT "${CPP_names}" STREQUAL "" )
        build_executables ( CPP_names _CPPsources )
    endif ()
endfunction ( generate_executables _dir )