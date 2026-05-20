cmake_minimum_required(VERSION 3.15)

foreach(req_var IN ITEMS TEST_NAME TD_EXECUTABLE INPUT_FILE WORK_DIR OUTPUT_FILE)
  if(NOT DEFINED ${req_var} OR "${${req_var}}" STREQUAL "")
    message(FATAL_ERROR "${req_var} is required")
  endif()
endforeach()

if(NOT DEFINED CHECK_STRUCTURE)
  set(CHECK_STRUCTURE OFF)
endif()

if(NOT DEFINED USE_SCRIPT_DEVICE)
  set(USE_SCRIPT_DEVICE OFF)
endif()

file(REMOVE_RECURSE "${WORK_DIR}")
file(MAKE_DIRECTORY "${WORK_DIR}")

set(work_input "${WORK_DIR}/input.top")
file(COPY_FILE "${INPUT_FILE}" "${work_input}")

if(USE_SCRIPT_DEVICE)
  set(td_command "${TD_EXECUTABLE}" "${work_input}")
else()
  set(td_command "${TD_EXECUTABLE}" "-d" "postscr" "${work_input}")
endif()

execute_process(
  COMMAND ${td_command}
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

set(output_path "${WORK_DIR}/${OUTPUT_FILE}")
if(NOT EXISTS "${output_path}" AND NOT USE_SCRIPT_DEVICE)
  get_filename_component(work_input_name "${work_input}" NAME)
  get_filename_component(work_input_stem "${work_input}" NAME_WE)
  foreach(candidate IN ITEMS "${work_input_stem}.ps" "${work_input_name}.ps")
    if(EXISTS "${WORK_DIR}/${candidate}")
      set(output_path "${WORK_DIR}/${candidate}")
      break()
    endif()
  endforeach()
endif()

if(NOT EXISTS "${output_path}")
  file(GLOB work_dir_entries LIST_DIRECTORIES true "${WORK_DIR}/*")
  string(REPLACE ";" "\n  " work_dir_entries_text "${work_dir_entries}")
  message(FATAL_ERROR
    "${TEST_NAME} did not create expected PostScript file '${output_path}'\n"
    "work directory entries:\n  ${work_dir_entries_text}\n"
    "stdout:\n${td_stdout}\n"
    "stderr:\n${td_stderr}\n")
endif()

file(SIZE "${output_path}" output_size)
if(output_size EQUAL 0)
  message(FATAL_ERROR "${TEST_NAME} created empty PostScript file '${output_path}'")
endif()

if(CHECK_STRUCTURE)
  file(READ "${output_path}" ps_output)
  if(NOT ps_output MATCHES "^%!PS-Adobe")
    message(FATAL_ERROR "${TEST_NAME} output is missing a PostScript header")
  endif()
  if(NOT ps_output MATCHES "%%BoundingBox:")
    message(FATAL_ERROR "${TEST_NAME} output is missing a BoundingBox comment")
  endif()
  if(NOT ps_output MATCHES "showpage")
    message(FATAL_ERROR "${TEST_NAME} output is missing showpage")
  endif()
endif()
