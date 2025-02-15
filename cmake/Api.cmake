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

    target_compile_options ( ${_target_name} PRIVATE -save-temps=obj )
    target_compile_options ( ${_target_name} PRIVATE
        -Wa,-a,-ad > ${debug_ARCHIVES}/${_target_name}.cod
    )
    target_link_options ( ${_target_name} PRIVATE
        -Wl,-Map=${debug_ARCHIVES}/${_target_name}.map
    )

    # Generate disassembler files
    add_custom_command (
        TARGET ${_target_name} POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -S --source-comment="[@@@SOURCES@@@]" ${CMAKE_CURRENT_BINARY_DIR}/${_target_name} > ${debug_ARCHIVES}/${_target_name}.disasm
        COMMENT "@@@@@@@@@ Generating Disassembler Information @@@@@@@@@@"
        VERBATIM
    )
endfunction ( more_debug_info _target_name )
