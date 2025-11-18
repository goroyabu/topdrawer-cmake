cmake_minimum_required(VERSION 3.15)
project(td VERSION 0.1 LANGUAGES C Fortran)

include(GNUInstallDirs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(FetchAndUnpack)
fetch_and_unpack_configure_dirs()

find_package(ugs REQUIRED)
find_package(f2c REQUIRED)
find_package(X11 REQUIRED COMPONENTS Xt Xmu)
message(STATUS "X11_FOUND = ${X11_FOUND}")
message(STATUS "X11_INCLUDE_DIR = ${X11_INCLUDE_DIR}")
message(STATUS "X11_LIBRARIES = ${X11_LIBRARIES}")
message(STATUS "X11_Xaw_LIB = ${X11_Xaw_LIB}")
message(STATUS "X11_Xmu_LIB = ${X11_Xmu_LIB}")
message(STATUS "X11_Xt_LIB = ${X11_Xt_LIB}")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ------------------------------------------------------------
# Options
# ------------------------------------------------------------
option(NET_FETCH "Allow CMake to download upstream archives when they are missing." ON)

# ------------------------------------------------------------
# Layout / Source acquisition
# ------------------------------------------------------------
set(TOPDRAWER_ARCHIVE_NAME "topdrawer_20071207.tar.gz")
set(TOPDRAWER_UPSTREAM_URL "http://ftp.riken.go.jp/iris/OLD/topdrawer/${TOPDRAWER_ARCHIVE_NAME}")
set(TOPDRAWER_ARCHIVE_SHA256 "a3c00ee7b4265bfe56040fa6640f1f2bf9fc2e594117bc84464f26b000c8539f")

set(TOPDRAWER_LOCAL_ARCHIVE "${ARCHIVE_DIR}/${TOPDRAWER_ARCHIVE_NAME}")
resolve_input_file(
    TOPDRAWER_ARCHIVE_PATH
    "${TOPDRAWER_UPSTREAM_URL}"
    "${TOPDRAWER_ARCHIVE_SHA256}"
    "${TOPDRAWER_LOCAL_ARCHIVE}"
)

set(TOPDRAWER_VENDOR_DIR "${CMAKE_BINARY_DIR}/vendor")
set(TOPDRAWER_GENERATED_DIR "${CMAKE_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${TOPDRAWER_VENDOR_DIR}" "${TOPDRAWER_GENERATED_DIR}")

set(TOPDRAWER_SOURCE_ROOT "${TOPDRAWER_VENDOR_DIR}/topdrawer")
if(EXISTS "${TOPDRAWER_SOURCE_ROOT}")
    file(REMOVE_RECURSE "${TOPDRAWER_SOURCE_ROOT}")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${TOPDRAWER_ARCHIVE_PATH}"
    WORKING_DIRECTORY "${TOPDRAWER_VENDOR_DIR}"
    RESULT_VARIABLE TOPDRAWER_TAR_RESULT
)
if(NOT TOPDRAWER_TAR_RESULT EQUAL 0)
    message(FATAL_ERROR "Extraction of ${TOPDRAWER_ARCHIVE_PATH} failed with code ${TOPDRAWER_TAR_RESULT}")
endif()

# ------------------------------------------------------------
# Enumerate sources
# ------------------------------------------------------------
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        "-DTOPDRAWER_ROOT:PATH=${TOPDRAWER_SOURCE_ROOT}"
        -P "${CMAKE_SOURCE_DIR}/cmake/TdPatchSources.cmake"
    RESULT_VARIABLE TOPDRAWER_PATCH_RESULT
)
if(NOT TOPDRAWER_PATCH_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to apply source adjustments (exit code ${TOPDRAWER_PATCH_RESULT}).")
endif()

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------
set(TOPDRAWER_SRC_DIR "${TOPDRAWER_SOURCE_ROOT}/src")
set(TOPDRAWER_MISC_DIR "${TOPDRAWER_SOURCE_ROOT}/misc")

set(misc_source_paths)
set(
    misc_source_names
    misc/clock.c misc/freq.f misc/gamma.f misc/intrac.c
    misc/length.f misc/minuit.f misc/noarg.f misc/sigwait.c
    misc/exit.c misc/fdate.c misc/time.c
)
foreach(src_name IN LISTS misc_source_names)
    list(APPEND misc_source_paths "${TOPDRAWER_SOURCE_ROOT}/${src_name}")
endforeach()

add_library(misc STATIC ${misc_source_paths})
target_compile_options(misc PRIVATE
    $<$<AND:$<PLATFORM_ID:Darwin>,$<COMPILE_LANGUAGE:Fortran>>:
        -O2 -std=legacy -fbackslash -fallow-invalid-boz -fno-automatic -finit-local-zero -funroll-loops -fomit-frame-pointer -ftree-vectorize -flat_namespace>
    $<$<AND:$<PLATFORM_ID:Darwin>,$<COMPILE_LANGUAGE:C>>: -O2 -DIUCLC=0001000 -ftree-vectorize>
)
target_include_directories(misc PRIVATE ${X11_INCLUDE_DIR} ${TOPDRAWER_SRC_DIR})
target_link_libraries(misc PRIVATE f2c::f2c_runtime)
if(F2C_INCLUDE_DIR)
    target_include_directories(misc PRIVATE "${F2C_INCLUDE_DIR}")
endif()

set(td_source_paths)
set(
    td_source_names
    readpr_.c
    hb_search_id.f help.f help_.c readx_.c
    smctrl.f t2axes.f t2cntr.f t2del.f
    t2fft.f t2fill.f t2fit.f t2main.f
    t2mesh.f t2plot.f t2savd.f t2set.f
    t2setc.f t2seth4.f t2show.f t2smooth.f
    t2spline.f t2tabl.f t2timf.f t2xfrm.f
    td.f td2ugs.f tdtext.f token.f
    txline.f txxug77.f tdend.f
)
foreach(src_name IN LISTS td_source_names)
    list(APPEND td_source_paths "${TOPDRAWER_SRC_DIR}/${src_name}")
endforeach()

add_executable(${PROJECT_NAME} ${td_source_paths})
target_compile_options(${PROJECT_NAME} PRIVATE
    $<$<AND:$<PLATFORM_ID:Darwin>,$<COMPILE_LANGUAGE:Fortran>>:
        -O2 -std=legacy -fbackslash -fallow-invalid-boz -fno-automatic -finit-local-zero -funroll-loops -fomit-frame-pointer -ftree-vectorize -flat_namespace>
    $<$<AND:$<PLATFORM_ID:Darwin>,$<COMPILE_LANGUAGE:C>>: -O2 -DIUCLC=0001000 -ftree-vectorize>
)
target_include_directories(${PROJECT_NAME} PRIVATE ${X11_INCLUDE_DIR} ${TOPDRAWER_SRC_DIR})
target_link_libraries(
    ${PROJECT_NAME} PRIVATE
    misc ugs::ugs f2c::f2c_runtime
    ${X11_LIBRARIES} ${X11_Xaw_LIB} ${X11_Xmu_LIB} ${X11_Xt_LIB}
)

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

install(FILES "${TOPDRAWER_SOURCE_ROOT}/topdrawer.gih"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/td")

# ---------------------------------------------------------------------------
# Uninstall target
# ---------------------------------------------------------------------------
set(_UNINSTALL_IN "${CMAKE_SOURCE_DIR}/cmake/Uninstall.cmake.in")
if(EXISTS "${_UNINSTALL_IN}")
  configure_file("${_UNINSTALL_IN}" "${CMAKE_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
  add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P "${CMAKE_BINARY_DIR}/cmake_uninstall.cmake"
    COMMENT "Uninstall previously installed files")
else()
  message(WARNING "cmake/Uninstall.cmake.in not found; 'uninstall' target is disabled.")
endif()

# ---------------------------------------------------------------------------
# Cleaning policy
# - Default `clean` removes build artefacts only. It DOES NOT remove:
#   * source archives in ${ARCHIVE_DIR} (user-provided)
#   * downloaded archives in ${DOWNLOAD_CACHE_DIR}
# Optional: remove download cache (use with care)
add_download_cleanup_target(clean_downloads)

# ---------------------------------------------------------------------------
# Test
# ---------------------------------------------------------------------------
# include(CTest)
# if(BUILD_TESTING AND EXISTS "${CMAKE_SOURCE_DIR}/tests/CMakeLists.txt")
#     add_subdirectory(tests)
# endif()
