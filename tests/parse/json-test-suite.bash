#!/bin/bash
source "test-bootstrap.bash"

function test_parse_pass {
  local filepath="$1" 
  $(cat "$filepath" | ./jp -s 2>/dev/null)
  if [ $? -eq 0 ];then
    pass "$filepath parses as expected"
  else
    fail "$filepath unexpectedly fails to parse"
  fi
}

for file in tests/share/JSONTestSuite/test_parsing/y_*;do
  test_parse_pass "$file"
done

function test_parse_fail {
  local filepath="$1" 
  $(cat "$filepath" | ./jp -s 2>/dev/null)
  if [ $? -gt 0 ];then
    pass "$filepath fails to parses as expected"
  else
    fail "$filepath unexpectedly parses"
  fi
}

for file in tests/share/JSONTestSuite/test_parsing/n_*;do
  test_parse_fail "$file"
done

function test_parse_optional {
  local filepath="$1" result="pass"
  $(cat "$filepath" | ./jp -s 2>/dev/null)
  [ $? -gt 0 ] && result="fail"
  pass "$filepath implementation $result"
}

for file in tests/share/JSONTestSuite/test_parsing/i_*;do
  test_parse_optional "$file"
done

end
