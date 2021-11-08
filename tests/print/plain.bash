#!/bin/bash
source "test-bootstrap.bash"
IFS=

expect='[1,2,3]'
arrays=$(./jp $expect)
if [ "$arrays" = $expect ];then
  pass "plain output is default on non-tty"
else
  printf -v arraysesc "%q" "$arrays"
  fail "plain output is default on non-tty: $arraysesc"
fi

which socat 1>/dev/null # to simulate tty
if [ $? -eq 0 ];then
  output=$(socat -u -t0 EXEC:"./jp -P $expect",pty -)
  if [ "$output" = $expect$'\r' ];then
    pass "-P forces plain output"
  else
    printf -v outputesc "%q" "$output"
    fail "-P doesn't force plain output: $outputesc"
  fi
fi
end
