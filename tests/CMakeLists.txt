set(TD_TEST_CASES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cases")
set(TD_POSTSCRIPT_FIXTURES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/postscript/fixtures")

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
  cmake_parse_arguments(TD_POSTSCRIPT "${options}" "${oneValueArgs}" "" ${ARGN})

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
