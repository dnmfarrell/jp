#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(echo 1 | ./jp .pop .drop 2>/dev/null)
if [ $? -eq 1 ];then
  pass "drop empty stack errors"
else
  fail "drop empty stack does not error"
fi

$(echo 1 | ./jp .drop 2>/dev/null)
if [ $? -eq 1 ];then
  pass "drop more items than stack errors"
else
  fail "drop drop more items than stack doesn't error"
fi

$(echo 1 | ./jp 2.5 .drop 2>/dev/null)
if [ $? -eq 1 ];then
  pass "drop non-integer errors"
else
  fail "drop non-integer doesn't error"
fi

one=$(./jp 1 '["b"]' '["a"]' 1 .drop)
if [ "$one" = $'["b"]\n1' ];then
  pass "drop one"
else
  printf -v oneesc "%q" "$one"
  fail "drop one returns: $oneesc"
fi

five=$(echo 1 | ./jp 2 3 4 5 5 .drop)
if [ "$five" = '' ];then
  pass "drop five"
else
  printf -v fiveesc "%q" "$five"
  fail "drop five returns: $fiveesc"
fi

end
