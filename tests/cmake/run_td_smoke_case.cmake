cmake_minimum_required(VERSION 3.15)

foreach(req_var IN ITEMS TEST_NAME TD_EXECUTABLE INPUT_FILE EXPECTED_FILE WORK_DIR)
  if(NOT DEFINED ${req_var} OR "${${req_var}}" STREQUAL "")
    message(FATAL_ERROR "${req_var} is required")
  endif()
endforeach()

file(MAKE_DIRECTORY "${WORK_DIR}")
file(REMOVE_RECURSE "${WORK_DIR}")
file(MAKE_DIRECTORY "${WORK_DIR}")

execute_process(
  COMMAND /bin/sh -c "\"$1\" -d postscr < \"$2\"" sh "${TD_EXECUTABLE}" "${INPUT_FILE}"
  WORKING_DIRECTORY "${WORK_DIR}"
  RESULT_VARIABLE td_result
  OUTPUT_VARIABLE td_stdout
  ERROR_VARIABLE td_stderr
)

string(REPLACE "\r\n" "\n" td_stdout "${td_stdout}")
string(REPLACE "\r\n" "\n" td_stderr "${td_stderr}")
set(td_output "${td_stdout}${td_stderr}")

if(NOT td_result EQUAL 0)
  message(FATAL_ERROR
    "${TEST_NAME} failed with exit code ${td_result}\n"
    "stdout:\n${td_stdout}\n"
    "stderr:\n${td_stderr}\n")
endif()

if(td_output MATCHES "\\*\\*\\* ERROR \\*\\*\\*" OR td_output MATCHES "ERROR FOUND BY THE UNIFIED GRAPHICS SYSTEM")
  message(FATAL_ERROR
    "${TEST_NAME} reported an execution error\n"
    "stdout:\n${td_stdout}\n"
    "stderr:\n${td_stderr}\n")
endif()

file(READ "${EXPECTED_FILE}" expected_regex)
string(STRIP "${expected_regex}" expected_regex)

if(NOT td_output MATCHES "${expected_regex}")
  message(FATAL_ERROR
    "${TEST_NAME} output did not match expected regex '${expected_regex}'\n"
    "stdout:\n${td_stdout}\n"
    "stderr:\n${td_stderr}\n")
endif()
