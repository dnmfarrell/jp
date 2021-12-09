#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .cons 2>/dev/null)
if [ $? -ne 0 ];then
  pass "cons without args errors"
else
  fail "cons without args does not error"
fi

$(./jp 1 .cons 2>/dev/null)
if [ $? -ne 0 ];then
  pass "cons one arg errors"
else
  fail "cons one arg does not error"
fi

$(./jp 1 2 .cons 2>/dev/null)
if [ $? -ne 0 ];then
  pass "cons no array errors"
else
  fail "cons no array does not error"
fi

empty=$(./jp [] [] .cons)
if [ "$empty" = $'[[]]' ];then
  pass "cons two empty arrays"
else
  printf -v emptyesc "%q" "$empty"
  fail "cons two empty arrays returns: $emptyesc"
fi

one=$(./jp [] 1 .cons)
if [ "$one" = $'[1]' ];then
  pass "cons into empty array returns [1]"
else
  printf -v oneesc "%q" "$one"
  fail "cons into empty array returns: $oneesc"
fi

two=$(./jp [2] 1 .cons)
if [ "$two" = $'[1,2]' ];then
  pass "cons into an array returns [1,2]"
else
  printf -v twoesc "%q" "$two"
  fail "cons into an array returns: $twoesc"
fi

end
