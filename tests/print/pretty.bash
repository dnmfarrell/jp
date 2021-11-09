#!/bin/bash
source "test-bootstrap.bash"
IFS=

expect=$'[\n  1,\n  2,\n  3\n]'
output=$(./jp -pn $expect)
if [ "$output" = $expect ];then
  pass "-p forces pretty output on non-tty"
else
  printf -v outputesc "%q" "$output"
  fail "-p doesn't force pretty output on non-tty: $outputesc"
fi

expect=$'[\n  1,\n  2,\n  [\n    3,\n    4,\n    {\n      "a": 5,\n      "b": 6\n    }\n  ],\n  7\n]'
output=$(./jp -p '[1,2,[3,4,{"a":5,"b":6}],7]')
if [ "$output" = $expect ];then
  pass "pretty indents as expected"
else
  printf -v outputesc "%q" "$output"
  fail "pretty doesn't indent as expected: $outputesc"
fi

which socat 1>/dev/null # to simulate tty
if [ $? -eq 0 ];then
  expect=$'[\r\n  1,\r\n  2,\r\n  3\r\n]'
  output=$(socat -u -t0 EXEC:"./jp $expect",pty -)
  if [ "$output" = $expect$'\r' ];then
    pass "pretty is default on tty"
  else
    printf -v outputesc "%q" "$output"
    fail "pretty is not default on tty: $outputesc"
  fi
fi
end
