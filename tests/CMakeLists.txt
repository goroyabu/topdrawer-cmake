set(TD_TEST_CASES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cases")
set(TD_POSTSCRIPT_FIXTURES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/postscript/fixtures")

find_package(Python3 3.8 COMPONENTS Interpreter REQUIRED)

foreach(_check IN ITEMS postscript help uninstall)
  add_test(
    NAME "installed_td.${_check}"
    COMMAND "${Python3_EXECUTABLE}" -B "${CMAKE_CURRENT_SOURCE_DIR}/install/${_check}.py"
      --cmake "${CMAKE_COMMAND}"
      --build-dir "${CMAKE_BINARY_DIR}"
      --input "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_plot_points.top"
      --bindir "${CMAKE_INSTALL_BINDIR}"
      --datarootdir "${CMAKE_INSTALL_DATAROOTDIR}"
  )
  set_tests_properties("installed_td.${_check}" PROPERTIES
    LABELS install RUN_SERIAL TRUE TIMEOUT 60)
endforeach()

function(add_td_smoke_case case_name)
  set(options)
  set(oneValueArgs INPUT_FILE EXPECTED_FILE)
  cmake_parse_arguments(TD_CASE "${options}" "${oneValueArgs}" "" ${ARGN})

  if(NOT TD_CASE_INPUT_FILE OR NOT TD_CASE_EXPECTED_FILE)
    message(FATAL_ERROR "add_td_smoke_case requires INPUT_FILE and EXPECTED_FILE.")
  endif()

  set(_case_work_dir "${CMAKE_CURRENT_BINARY_DIR}/${case_name}")
  add_test(
    NAME "${case_name}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DTEST_NAME=${case_name}"
      "-DTD_EXECUTABLE=$<TARGET_FILE:td>"
      "-DINPUT_FILE=${TD_CASE_INPUT_FILE}"
      "-DEXPECTED_FILE=${TD_CASE_EXPECTED_FILE}"
      "-DWORK_DIR=${_case_work_dir}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/run_td_smoke_case.cmake"
  )
  set_tests_properties("${case_name}" PROPERTIES LABELS "smoke")
endfunction()

function(add_td_postscript_case case_name)
  set(options CHECK_STRUCTURE USE_SCRIPT_DEVICE)
  set(oneValueArgs INPUT_FILE OUTPUT_FILE)
  set(multiValueArgs EXTRA_INPUT_FILES)
  cmake_parse_arguments(TD_POSTSCRIPT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT TD_POSTSCRIPT_INPUT_FILE)
    message(FATAL_ERROR "add_td_postscript_case requires INPUT_FILE.")
  endif()

  if(NOT TD_POSTSCRIPT_OUTPUT_FILE)
    if(TD_POSTSCRIPT_USE_SCRIPT_DEVICE)
      set(TD_POSTSCRIPT_OUTPUT_FILE "explicit-device.ps")
    else()
      set(TD_POSTSCRIPT_OUTPUT_FILE "input.ps")
    endif()
  endif()

  set(_extra_input_files_arg "")
  if(TD_POSTSCRIPT_EXTRA_INPUT_FILES)
    list(JOIN TD_POSTSCRIPT_EXTRA_INPUT_FILES "|" _extra_input_files_arg)
  endif()

  set(_case_work_dir "${CMAKE_CURRENT_BINARY_DIR}/${case_name}")
  add_test(
    NAME "${case_name}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DTEST_NAME=${case_name}"
      "-DTD_EXECUTABLE=$<TARGET_FILE:td>"
      "-DINPUT_FILE=${TD_POSTSCRIPT_INPUT_FILE}"
      "-DOUTPUT_FILE=${TD_POSTSCRIPT_OUTPUT_FILE}"
      "-DWORK_DIR=${_case_work_dir}"
      "-DCHECK_STRUCTURE=$<BOOL:${TD_POSTSCRIPT_CHECK_STRUCTURE}>"
      "-DUSE_SCRIPT_DEVICE=$<BOOL:${TD_POSTSCRIPT_USE_SCRIPT_DEVICE}>"
      "-DEXTRA_INPUT_FILES=${_extra_input_files_arg}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/run_td_postscript_case.cmake"
  )

  if(TD_POSTSCRIPT_CHECK_STRUCTURE)
    set_tests_properties("${case_name}" PROPERTIES LABELS "postscript;ps_structure")
  else()
    set_tests_properties("${case_name}" PROPERTIES LABELS "postscript;io")
  endif()
endfunction()

function(add_td_postscript_compare_case case_name)
  set(options)
  set(oneValueArgs LEFT_INPUT RIGHT_INPUT)
  cmake_parse_arguments(TD_COMPARE "${options}" "${oneValueArgs}" "" ${ARGN})

  if(NOT TD_COMPARE_LEFT_INPUT OR NOT TD_COMPARE_RIGHT_INPUT)
    message(FATAL_ERROR "add_td_postscript_compare_case requires LEFT_INPUT and RIGHT_INPUT.")
  endif()

  set(_case_work_dir "${CMAKE_CURRENT_BINARY_DIR}/${case_name}")
  add_test(
    NAME "${case_name}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DTEST_NAME=${case_name}"
      "-DTD_EXECUTABLE=$<TARGET_FILE:td>"
      "-DLEFT_INPUT=${TD_COMPARE_LEFT_INPUT}"
      "-DRIGHT_INPUT=${TD_COMPARE_RIGHT_INPUT}"
      "-DWORK_DIR=${_case_work_dir}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/run_td_postscript_compare.cmake"
  )
  set_tests_properties("${case_name}" PROPERTIES LABELS "postscript;command_output")
endfunction()

add_td_smoke_case(
  01_smoke
  INPUT_FILE "${TD_TEST_CASES_DIR}/01_smoke/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/01_smoke/expected.txt"
)

add_td_smoke_case(
  02_muon
  INPUT_FILE "${TD_TEST_CASES_DIR}/02_muon/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/02_muon/expected.txt"
)

add_td_smoke_case(
  03_two
  INPUT_FILE "${TD_TEST_CASES_DIR}/03_two/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/03_two/expected.txt"
)

add_td_smoke_case(
  04_scatter
  INPUT_FILE "${TD_TEST_CASES_DIR}/04_scatter/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/04_scatter/expected.txt"
)

add_td_smoke_case(
  05_3dim
  INPUT_FILE "${TD_TEST_CASES_DIR}/05_3dim/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/05_3dim/expected.txt"
)

add_td_smoke_case(
  06_fonts
  INPUT_FILE "${TD_TEST_CASES_DIR}/06_fonts/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/06_fonts/expected.txt"
)

add_td_postscript_case(
  io_postscr_basic_plot
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_plot_points.top"
)

add_td_postscript_case(
  io_postscr_join
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_join_line.top"
)

add_td_postscript_case(
  io_postscr_histogram
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/histogram_basic.top"
)

add_td_postscript_case(
  io_device_file_explicit_name
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/device_output_file.top"
  OUTPUT_FILE "explicit-device.ps"
  USE_SCRIPT_DEVICE
)

add_td_postscript_case(
  io_external_input_order_dummy
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/external_input_order.top"
  EXTRA_INPUT_FILES "${TD_POSTSCRIPT_FIXTURES_DIR}/external_input_order.dat"
)

add_td_postscript_case(
  io_title_coordinate_labels
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/title_coordinate_labels.top"
)

add_td_postscript_case(
  io_errorbar_reordered_data
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/errorbar_reordered_data.top"
)

add_td_postscript_case(
  io_window_mixed_panels
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/window_mixed_panels.top"
)

add_td_postscript_case(
  io_axis_titles_outline
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/axis_titles_outline.top"
)

add_td_postscript_case(
  ps_structure_basic_plot
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_plot_points.top"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_join
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_join_line.top"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_histogram
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/histogram_basic.top"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_external_input
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/external_input_order.top"
  EXTRA_INPUT_FILES "${TD_POSTSCRIPT_FIXTURES_DIR}/external_input_order.dat"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_title_coordinate_labels
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/title_coordinate_labels.top"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_errorbar_reordered_data
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/errorbar_reordered_data.top"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_window_mixed_panels
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/window_mixed_panels.top"
  CHECK_STRUCTURE
)

add_td_postscript_case(
  ps_structure_axis_titles_outline
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/axis_titles_outline.top"
  CHECK_STRUCTURE
)

add_td_postscript_compare_case(
  command_output_plot_vs_join_differs
  LEFT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_plot_points.top"
  RIGHT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_join_line.top"
)

add_td_postscript_compare_case(
  command_output_histogram_differs_from_plot
  LEFT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/histogram_basic.top"
  RIGHT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_plot_points.top"
)

add_td_postscript_compare_case(
  command_output_errorbar_differs_from_no_errors
  LEFT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/errorbar_reordered_data.top"
  RIGHT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/errorbar_no_errors.top"
)

add_td_postscript_compare_case(
  command_output_window_mixed_panels_differs_from_basic_plot
  LEFT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/window_mixed_panels.top"
  RIGHT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/basic_plot_points.top"
)

add_td_postscript_compare_case(
  command_output_duplex_glyph_a_differs_from_two
  LEFT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/duplex_glyph_a.top"
  RIGHT_INPUT "${TD_POSTSCRIPT_FIXTURES_DIR}/duplex_glyph_two.top"
)

# Acquisition tests use synthetic inputs and local file URLs, without networking.
foreach(_case
  local_valid
  local_mismatch_strict
  cache_valid
  cache_mismatch_strict
  download_valid
  download_mismatch_strict
  no_fallback_after_mismatch
  local_mismatch_allowed
  cache_mismatch_allowed
  download_mismatch_allowed
  valid_archive_allowed_mode_warning
  no_fallback_after_mismatch_allowed
  missing_input_allowed
  download_failure_allowed
  hint_precedence
  archive_directory_fallback
  cache_no_fallback
  offline_cache_strict
  download_failure_strict)
  add_test(NAME "archive_hash.${_case}"
    COMMAND "${CMAKE_COMMAND}"
      "-DTEST_CASE=${_case}"
      "-DFETCH_MODULE=${PROJECT_SOURCE_DIR}/cmake/FetchAndUnpack.cmake"
      "-DTEST_ROOT=${CMAKE_CURRENT_BINARY_DIR}/archive-hash-tests/${_case}"
      "-DRESOLVE_SCRIPT=${CMAKE_CURRENT_SOURCE_DIR}/archive_hash/ResolveArchive.cmake"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/archive_hash/RunArchiveHashTest.cmake")
  set_tests_properties("archive_hash.${_case}" PROPERTIES
    LABELS "archive-integrity" TIMEOUT 30)
endforeach()

# These direct ABI probes currently qualify GNU Fortran only.
option(TD_HELPER_SANITIZERS "Instrument the legacy helper probes with ASan/UBSan" OFF)
if(TD_HELPER_SANITIZERS AND NOT (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU"
    AND CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" AND CMAKE_SYSTEM_NAME STREQUAL "Linux"))
  message(FATAL_ERROR "TD_HELPER_SANITIZERS currently requires GNU Fortran and GCC/Clang on Linux")
endif()
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  # Extract the actual prepared routines, including their EXTERNAL declarations.
  # This avoids a second hand-maintained implementation of the TD call sites.
  file(READ "${TOPDRAWER_SRC_DIR}/help.f" _help_source)
  set(_helper_routines "${CMAKE_CURRENT_BINARY_DIR}/legacy-helper-routines.f")
  file(WRITE "${_helper_routines}" "")
  foreach(_name RELTIM T2_WAIT TDTIME DATE)
    if(_name STREQUAL "RELTIM")
      set(_prefix "      REAL FUNCTION ${_name}(")
    else()
      set(_prefix "      SUBROUTINE ${_name}(")
    endif()
    string(FIND "${_help_source}" "${_prefix}" _start)
    if(_start LESS 0)
      message(FATAL_ERROR "Cannot locate upstream helper ${_name}")
    endif()
    string(SUBSTRING "${_help_source}" ${_start} -1 _tail)
    string(FIND "${_tail}" "\n      END\n" _end)
    if(_end LESS 0)
      message(FATAL_ERROR "Cannot locate end of upstream helper ${_name}")
    endif()
    math(EXPR _length "${_end} + 11")
    string(SUBSTRING "${_tail}" 0 ${_length} _routine)
    file(APPEND "${_helper_routines}" "${_routine}\n")
  endforeach()

  add_library(td_helper_objects OBJECT
    "${TOPDRAWER_MISC_DIR}/exit.c" "${TOPDRAWER_MISC_DIR}/fdate.c"
    legacy_helpers/TimeAbi.c)
  target_include_directories(td_helper_objects PRIVATE "${TOPDRAWER_MISC_DIR}")
  target_link_libraries(td_helper_objects PRIVATE f2c::f2c_runtime)
  if(F2C_INCLUDE_DIR)
    target_include_directories(td_helper_objects PRIVATE "${F2C_INCLUDE_DIR}")
  endif()
  set_target_properties(td_helper_objects PROPERTIES C_STANDARD 11 C_STANDARD_REQUIRED YES)
  add_executable(td_helper_probe legacy_helpers/Probe.f90 "${_helper_routines}")
  add_executable(td_exit_probe legacy_helpers/ExitProbe.f90)
  foreach(_target td_helper_probe td_exit_probe)
    target_link_libraries(${_target} PRIVATE td_helper_objects f2c::f2c_runtime)
    target_compile_options(${_target} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:-std=legacy>)
  endforeach()
  if(TD_HELPER_SANITIZERS)
    foreach(_target td_helper_objects td_helper_probe td_exit_probe)
      target_compile_options(${_target} PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer -g)
    endforeach()
    foreach(_target td_helper_probe td_exit_probe)
      target_link_options(${_target} PRIVATE -fsanitize=address,undefined)
    endforeach()
  endif()
  foreach(_case datetime short long exit0 exit3)
    set(_target td_helper_probe)
    set(_mode "${_case}")
    set(_exit 0)
    if(_case MATCHES "^exit([03])$")
      set(_target td_exit_probe)
      set(_mode "${CMAKE_MATCH_1}")
      set(_exit "${_mode}")
    elseif(_case STREQUAL "short" OR _case STREQUAL "long")
      set(_exit 1)
    endif()
    add_test(NAME "legacy_helpers.${_case}" COMMAND "${CMAKE_COMMAND}"
      "-DPROGRAM=$<TARGET_FILE:${_target}>" "-DMODE=${_mode}"
      "-DEXPECTED_EXIT=${_exit}"
      "-DWORK_DIR=${CMAKE_CURRENT_BINARY_DIR}/legacy-helpers/${_case}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/legacy_helpers/RunProbe.cmake")
    set_tests_properties("legacy_helpers.${_case}" PROPERTIES
      LABELS "helper-contract" TIMEOUT 20
      ENVIRONMENT "LC_ALL=C;TZ=UTC;ASAN_OPTIONS=detect_leaks=0;UBSAN_OPTIONS=halt_on_error=1")
  endforeach()
  add_test(NAME legacy_helpers.linkage COMMAND "${CMAKE_COMMAND}"
    "-DNM=${CMAKE_NM}" "-DPROGRAM=$<TARGET_FILE:td>"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/legacy_helpers/VerifySymbols.cmake")
  set_tests_properties(legacy_helpers.linkage PROPERTIES LABELS "helper-contract" TIMEOUT 20)
endif()
