#!/bin/bash
source "test-bootstrap.bash"
IFS=

expect=$'[\n  1,\n  2,\n  3\n]'
output=$(jp -pn $expect)
if [ "$output" = $expect ];then
  pass "-p forces pretty output on non-tty"
else
  printf -v outputesc "%q" "$output"
  fail "-p doesn't force pretty output on non-tty: $outputesc"
fi

which socat 1>/dev/null # to simulate tty
if [ $? -eq 0 ];then
  expect=$'[\r\n  1,\r\n  2,\r\n  3\r\n]'
  output=$(socat -u -t0 EXEC:"jp -n $expect",pty -)
  if [ "$output" = $expect$'\r' ];then
    pass "pretty is default on tty"
  else
    printf -v outputesc "%q" "$output"
    fail "pretty is not default on tty: $outputesc"
  fi
fi
end
