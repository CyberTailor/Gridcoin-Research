set(LIBDB_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/libdb_build)
set(libdb_cxx_library ${LIBDB_BUILD_DIR}/libdb_cxx${CMAKE_STATIC_LIBRARY_SUFFIX})

add_library(libdb_cxx STATIC IMPORTED GLOBAL)
set_target_properties(libdb_cxx PROPERTIES
    IMPORTED_LOCATION ${libdb_cxx_library}
)
target_include_directories(libdb_cxx INTERFACE ${LIBDB_BUILD_DIR})


# Configure
# =========
set(BDB_FLAGS
    --disable-java
    --disable-jdbc
    --disable-replication
    --enable-cxx
)
if(ENABLE_PIE)
    list(APPEND BDB_FLAGS
        --with-pic
    )
endif()
if(MINGW)
    list(APPEND BDB_FLAGS
        --enable-mingw
    )
endif()

file(MAKE_DIRECTORY ${LIBDB_BUILD_DIR})

if(CMAKE_VERSION VERSION_LESS 3.19)
    execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/dist/configure ${BDB_FLAGS}
        WORKING_DIRECTORY ${LIBDB_BUILD_DIR}
        RESULT_VARIABLE configure_status
    )
    if(NOT configure_status EQUAL 0)
        message(FATAL_ERROR "BerkeleyDB configure failed")
    endif()
else()
    execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/dist/configure ${BDB_FLAGS}
        WORKING_DIRECTORY ${LIBDB_BUILD_DIR}
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()


# Make
# ====

include(ProcessorCount)
ProcessorCount(N)
if(N EQUAL 0)
    set(N 1)
endif()

set(MAKEOPTS "-j${N}" CACHE STRING "Options for the 'make' program")

add_custom_command(OUTPUT ${libdb_cxx_library}
    COMMAND make ${MAKEOPTS}
    WORKING_DIRECTORY ${LIBDB_BUILD_DIR}
    USES_TERMINAL
)
add_custom_target(make_libdb_cxx DEPENDS ${libdb_cxx_library})
add_dependencies(libdb_cxx make_libdb_cxx)
