set(TD_TEST_CASES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cases")

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
      -P "${CMAKE_CURRENT_SOURCE_DIR}/run_td_case.cmake"
  )
  set_tests_properties("${case_name}" PROPERTIES LABELS "smoke")
endfunction()

add_td_smoke_case(
  01_smoke
  INPUT_FILE "${TD_TEST_CASES_DIR}/01_smoke/input.top"
  EXPECTED_FILE "${TD_TEST_CASES_DIR}/01_smoke/expected.txt"
)
