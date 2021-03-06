#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .swap 2>/dev/null)
if [ $? -ne 0 ];then
  pass "swap empty stack errors"
else
  fail "swap empty stack does not error"
fi

$(./jp 1 .swap 2>/dev/null)
if [ $? -ne 0 ];then
  pass "swap one stack errors"
else
  fail "swap one stack does not error"
fi

twice=$(./jp '[" a c "]' '["b"]' .swap .swap)
if [ "$twice" = $'["b"]\n[" a c "]' ];then
  pass "swap twice"
else
  printf -v twiceesc "%q" "$twice"
  fail "swap twice returns: $twiceesc"
fi

two=$(echo '["a"]' | ./jp '["b"]' .swap)
if [ "$two" = $'["a"]\n["b"]' ];then
  pass "swap two stack"
else
  printf -v twoesc "%q" "$two"
  fail "swap two stack returns: $twoesc"
fi

three=$(echo '["c"]' | ./jp '["b"]' '["a"]' .swap)
if [ "$three" = $'["b"]\n["a"]\n["c"]' ];then
  pass "swap three stack"
else
  printf -v threeesc "%q" "$three"
  fail "swap three stack returns: $threeesc"
fi

end
