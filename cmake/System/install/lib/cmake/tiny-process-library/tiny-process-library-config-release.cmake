#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "tiny-process-library::tiny-process-library" for configuration "Release"
set_property(TARGET tiny-process-library::tiny-process-library APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(tiny-process-library::tiny-process-library PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libtiny-process-library.so"
  IMPORTED_SONAME_RELEASE "libtiny-process-library.so"
  )

list(APPEND _cmake_import_check_targets tiny-process-library::tiny-process-library )
list(APPEND _cmake_import_check_files_for_tiny-process-library::tiny-process-library "${_IMPORT_PREFIX}/lib/libtiny-process-library.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
