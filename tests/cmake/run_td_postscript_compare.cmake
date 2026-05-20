cmake_minimum_required(VERSION 3.15)

foreach(req_var IN ITEMS TEST_NAME TD_EXECUTABLE LEFT_INPUT RIGHT_INPUT WORK_DIR)
  if(NOT DEFINED ${req_var} OR "${${req_var}}" STREQUAL "")
    message(FATAL_ERROR "${req_var} is required")
  endif()
endforeach()

file(REMOVE_RECURSE "${WORK_DIR}")
file(MAKE_DIRECTORY "${WORK_DIR}")

function(run_render input_file output_file stdout_var stderr_var)
  execute_process(
    COMMAND "${TD_EXECUTABLE}" "-d" "postscr,ddname=${output_file}" "${input_file}"
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
      "${TEST_NAME} failed while rendering '${input_file}' with exit code ${td_result}\n"
      "stdout:\n${td_stdout}\n"
      "stderr:\n${td_stderr}\n")
  endif()

  if(td_output MATCHES "\\*\\*\\* ERROR \\*\\*\\*" OR td_output MATCHES "ERROR FOUND BY THE UNIFIED GRAPHICS SYSTEM")
    message(FATAL_ERROR
      "${TEST_NAME} reported an execution error while rendering '${input_file}'\n"
      "stdout:\n${td_stdout}\n"
      "stderr:\n${td_stderr}\n")
  endif()

  set(output_path "${WORK_DIR}/${output_file}")
  if(NOT EXISTS "${output_path}")
    message(FATAL_ERROR "${TEST_NAME} did not create expected file '${output_path}'")
  endif()

  file(SIZE "${output_path}" output_size)
  if(output_size EQUAL 0)
    message(FATAL_ERROR "${TEST_NAME} created empty file '${output_path}'")
  endif()

  set(${stdout_var} "${td_stdout}" PARENT_SCOPE)
  set(${stderr_var} "${td_stderr}" PARENT_SCOPE)
endfunction()

run_render("${LEFT_INPUT}" "left.ps" left_stdout left_stderr)
run_render("${RIGHT_INPUT}" "right.ps" right_stdout right_stderr)

file(SHA256 "${WORK_DIR}/left.ps" left_sha)
file(SHA256 "${WORK_DIR}/right.ps" right_sha)

if(left_sha STREQUAL right_sha)
  message(FATAL_ERROR
    "${TEST_NAME} expected different PostScript output, but files are byte-identical\n"
    "left input: ${LEFT_INPUT}\n"
    "right input: ${RIGHT_INPUT}\n"
    "left stdout:\n${left_stdout}\n"
    "right stdout:\n${right_stdout}\n")
endif()
