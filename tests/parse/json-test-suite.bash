#!/bin/bash
source "test-bootstrap.bash"

jp_slow_tests=( \
  n_structure_100000_opening_arrays.json \
  n_structure_open_array_object.json )

function is_slow_test {
  for st in ${jp_slow_tests[@]};do
    [ "$1" = "$st" ] && return 0
  done
  return 1
}

jp_todo_tests=( \
  n_multidigit_number_then_00.json \
  n_string_unescaped_crtl_char.json \
  n_string_unescaped_newline.json \
  n_structure_null-byte-outside-string.json \
)

function is_todo_test {
  for st in ${jp_todo_tests[@]};do
    [ "$1" = "$st" ] && return 0
  done
  return 1
}

function test_parse_pass {
  local filepath="$1" filename="$2"
  if [ -z "$JP_TEST_SLOW" ] && is_slow_test "$filename";then
    skip "$filepath"
    return
  fi
  $(cat "$filepath" | ./jp -s 2>/dev/null)
  if [ $? -eq 0 ];then
    pass "$filename parses as expected"
  else
    fail "$filename unexpectedly fails to parse"
  fi
}

for file in tests/share/JSONTestSuite/test_parsing/y_*;do
  test_parse_pass "$file" "${file##*/}"
done

function test_parse_fail {
  local filepath="$1" filename="$2"
  if [ -z "$JP_TEST_SLOW" ] && is_slow_test "$filename";then
    skip "$filename"
    return
  fi
  if is_todo_test "$filename";then
    todo "$filename jp does not detect null bytes"
    return
  fi
  $(cat "$filepath" | ./jp -s 2>/dev/null)
  if [ $? -gt 0 ];then
    pass "$filename fails to parses as expected"
  else
    fail "$filename unexpectedly parses"
  fi
}

for file in tests/share/JSONTestSuite/test_parsing/n_*;do
  test_parse_fail "$file" "${file##*/}"
done

function test_parse_optional {
  local filepath="$1" filename="$2" result="pass"
  if [ -z "$JP_TEST_SLOW" ] && is_slow_test "$filename";then
    skip "$filename"
    return
  fi
  $(cat "$filepath" | ./jp -s 2>/dev/null)
  [ $? -gt 0 ] && result="fail"
  pass "$filename implementation $result"
}

for file in tests/share/JSONTestSuite/test_parsing/i_*;do
  test_parse_optional "$file" "${file##*/}"
done

end
