#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "libuv::uv_a" for configuration "Release"
set_property(TARGET libuv::uv_a APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(libuv::uv_a PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib64/libuv.a"
  )

list(APPEND _cmake_import_check_targets libuv::uv_a )
list(APPEND _cmake_import_check_files_for_libuv::uv_a "${_IMPORT_PREFIX}/lib64/libuv.a" )

# Import target "libuv::uv" for configuration "Release"
set_property(TARGET libuv::uv APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(libuv::uv PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib64/libuv.so.1.0.0"
  IMPORTED_SONAME_RELEASE "libuv.so.1"
  )

list(APPEND _cmake_import_check_targets libuv::uv )
list(APPEND _cmake_import_check_files_for_libuv::uv "${_IMPORT_PREFIX}/lib64/libuv.so.1.0.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
