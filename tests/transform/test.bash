#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(echo 1 | jp .pop .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test empty stack errors"
else
  fail "test empty stack does not error"
fi

$(echo null | jp .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test illegal operand type errors"
else
  fail "test illegal operand type does not error"
fi

$(echo 1 | jp "f" .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test mismatched types errors"
else
  fail "test mismatched types does not error"
fi

$(echo "f" | jp 1 .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test mismatched types errors"
else
  fail "test mismatched types does not error"
fi

nothing=$(echo 1 | jp .eq)
if [ "$nothing" = '[]' ];then
  pass "test one stack returns []"
else
  printf -v nothingesc "%q" "$nothing"
  fail "test one stack returns: $nothingesc"
fi

none=$(echo 1 | jp 2 3 5 .gt)
if [ "$none" = '[]' ];then
  pass "test no true cases returns []"
else
  printf -v noneesc "%q" "$none"
  fail "test no true cases returns: $noneesc"
fi

one=$(echo 1 | jp 2 3 1 .eq)
if [ "$one" = '[1]' ];then
  pass "test one true case"
else
  printf -v oneesc "%q" "$one"
  fail "test one true case returns: $oneesc"
fi

three=$(echo 1 | jp 2 3 1 .ge)
if [ "$three" = '[3,2,1]' ];then
  pass "test three true cases"
else
  printf -v threeesc "%q" "$three"
  fail "test three true cases returns: $threeesc"
fi

emptystr=$(echo '""' | jp '""' .eq)
if [ "$emptystr" = '[""]' ];then
  pass "test emptystr case"
else
  printf -v emptystresc "%q" "$emptystr"
  fail "test emptystr case returns: $emptystresc"
fi

end
