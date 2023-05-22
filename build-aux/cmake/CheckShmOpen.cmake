include(CheckCSourceCompiles)

if(UNIX)
    check_c_source_compiles("
        #include <sys/types.h>
        #include <sys/mman.h>

        int main() {
            shm_open(0, 0, 0);
            return 0;
        }"
        LIBRT_NOT_REQUIRED
    )

    if(LIBRT_NOT_REQUIRED)
        set(RT_LIBRARIES CACHE STRING "")
    else()
        set(RT_LIBRARIES CACHE STRING "-lrt")
    endif()
else()
    set(RT_LIBRARIES CACHE STRING "")
endif()
