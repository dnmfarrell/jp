#!/bin/bash
source "test-bootstrap.bash"
IFS=

empty=$(echo '{}' | jp .pop .count)
if [ "$empty" = '0' ];then
  pass "count on empty stack returns 0"
else
  printf -v emptyesc "%q" "$empty"
  fail "count on empty stack returns: $emptyesc"
fi

one=$(echo '{}' | jp .count)
if [ "$one" = '1' ];then
  pass "count on one stack returns 1"
else
  printf -v oneesc "%q" "$one"
  fail "count on one stack returns: $oneesc"
fi

five=$(echo 1 | jp 2 3 4 5 .count)
if [ "$five" = '5' ];then
  pass "count on five stack returns 5"
else
  printf -v fiveesc "%q" "$five"
  fail "count on five stack returns: $fiveesc"
fi

end
