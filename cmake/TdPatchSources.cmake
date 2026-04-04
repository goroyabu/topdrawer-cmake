cmake_minimum_required(VERSION 3.20)

if(NOT DEFINED TOPDRAWER_ROOT)
    message(FATAL_ERROR "TOPDRAWER_ROOT is not defined")
endif()

function(td_prepend_if_missing filepath line)
    if(NOT EXISTS "${filepath}")
        message(FATAL_ERROR "File not found: ${filepath}")
    endif()
    file(READ "${filepath}" _td_content)
    string(FIND "${_td_content}" "${line}" _td_found)
    if(_td_found EQUAL -1)
        string(PREPEND _td_content "${line}\n")
        file(WRITE "${filepath}" "${_td_content}")
    endif()
endfunction()

function(td_insert_after_first_line filepath line)
    if(NOT EXISTS "${filepath}")
        message(FATAL_ERROR "File not found: ${filepath}")
    endif()
    file(READ "${filepath}" _td_content)
    string(FIND "${_td_content}" "${line}" _td_found)
    if(_td_found GREATER -1)
        return()
    endif()
    string(FIND "${_td_content}" "\n" _td_newline)
    if(_td_newline EQUAL -1)
        set(_td_new "${_td_content}\n${line}\n")
    else()
        math(EXPR _td_after "${_td_newline} + 1")
        string(SUBSTRING "${_td_content}" 0 ${_td_after} _td_head)
        string(SUBSTRING "${_td_content}" ${_td_after} -1 _td_tail)
        set(_td_new "${_td_head}${line}\n${_td_tail}")
    endif()
    file(WRITE "${filepath}" "${_td_new}")
endfunction()

function(td_insert_before_token filepath token line)
    if(NOT EXISTS "${filepath}")
        message(FATAL_ERROR "File not found: ${filepath}")
    endif()
    file(READ "${filepath}" _td_content)
    string(FIND "${_td_content}" "${line}" _td_existing)
    if(_td_existing GREATER -1)
        return()
    endif()
    string(FIND "${_td_content}" "${token}" _td_pos)
    if(_td_pos EQUAL -1)
        message(WARNING "Token '${token}' not found in ${filepath}")
        return()
    endif()
    string(SUBSTRING "${_td_content}" 0 ${_td_pos} _td_head)
    string(SUBSTRING "${_td_content}" ${_td_pos} -1 _td_tail)
    set(_td_new "${_td_head}${line}\n${_td_tail}")
    file(WRITE "${filepath}" "${_td_new}")
endfunction()

function(td_remove_line_matches filepath pattern)
    if(NOT EXISTS "${filepath}")
        message(FATAL_ERROR "File not found: ${filepath}")
    endif()
    file(READ "${filepath}" _td_content)
    string(REGEX REPLACE "${pattern}" "" _td_new "${_td_content}")
    if(NOT _td_new STREQUAL _td_content)
        file(WRITE "${filepath}" "${_td_new}")
    endif()
endfunction()

function(td_comment_out_lines filepath)
    if(NOT EXISTS "${filepath}")
        message(FATAL_ERROR "File not found: ${filepath}")
    endif()
    file(READ "${filepath}" _td_content)
    set(_td_new "${_td_content}")
    foreach(item IN LISTS ARGN)
        string(REPLACE "${item}" "//${item}" _td_new "${_td_new}")
    endforeach()
    if(NOT _td_new STREQUAL _td_content)
        file(WRITE "${filepath}" "${_td_new}")
    endif()
endfunction()

function(td_replace_string filepath match replacement)
    if(NOT EXISTS "${filepath}")
        message(FATAL_ERROR "File not found: ${filepath}")
    endif()
    file(READ "${filepath}" _td_content)
    string(REPLACE "${match}" "${replacement}" _td_new "${_td_content}")
    if(_td_new STREQUAL _td_content)
        message(WARNING "Pattern '${match}' not found in ${filepath}")
    else()
        file(WRITE "${filepath}" "${_td_new}")
    endif()
endfunction()

set(_td_src_dir "${TOPDRAWER_ROOT}/src")
set(_td_misc_dir "${TOPDRAWER_ROOT}/misc")

td_remove_line_matches("${_td_src_dir}/readpr_.c" "[^\n]*ISC22[^\n]*\n")
td_insert_after_first_line("${_td_src_dir}/readpr_.c" "#include <stdlib.h> /* TD modern */")
td_replace_string("${_td_src_dir}/readpr_.c" "backspace()\n{" "static void backspace(void)\n{")
td_replace_string("${_td_src_dir}/readpr_.c" "register        i = start;" "register        int i = start;")

td_prepend_if_missing("${_td_src_dir}/help_.c" "#include <stdlib.h>")
td_insert_after_first_line("${_td_src_dir}/help_.c" "#include <string.h>")
td_comment_out_lines("${_td_src_dir}/help_.c"
    "extern int      strlen();"
    "extern char *strcpy();"
    "extern char *strncpy();"
    "extern char *strcat();"
    "extern char *strncat();"
    "extern char *malloc();"
)
td_replace_string("${_td_src_dir}/help_.c"
    "help0(keyword, path, subtopics)"
    "static int help0(keyword, path, subtopics)")
td_comment_out_lines("${_td_src_dir}/help_.c"
    "extern FILE *popen();"
    "extern int pclose();"
)

td_insert_after_first_line("${_td_src_dir}/readx_.c" "#include <string.h>")

td_prepend_if_missing("${_td_misc_dir}/exit.c" "#include <stdlib.h>")
td_insert_before_token("${_td_misc_dir}/fdate.c" "VOID fdate_" "void s_copy(char *, char *, ftnlen, ftnlen);")

# Fortran source adjustments
td_replace_string("${_td_src_dir}/t2del.f"
    "      JTEST1=ICHAR(CXYZ(IXYZ))"
    "      JTEST1=ICHAR(CXYZ(IXYZ)(1:1))")
td_replace_string("${_td_src_dir}/t2del.f"
    "      JTEST2=ICHAR(CXYZ(IXYZ))"
    "      JTEST2=ICHAR(CXYZ(IXYZ)(1:1))")
td_insert_before_token("${_td_src_dir}/td.f"
    "C     CALL T2_VIRT(ISIZE)"
    "      LOGICAL T2_VIRT,DMMY")
td_replace_string("${_td_misc_dir}/minuit.f"
    "      LOGICAL   LWARN, LREPOR, LIMSET, LNOLIM, LNEWMN, LPHEAD\nC\n      CFROM = 'SET LIM '"
    "      LOGICAL   LWARN, LREPOR, LIMSET, LNOLIM, LNEWMN, LPHEAD\n      EXTERNAL FCN,FUTIL\nC\n      CFROM = 'SET LIM '")
