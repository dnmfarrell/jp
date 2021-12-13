#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .t 2>/dev/null)
if [ $? -ne 0 ];then
  pass "t on empty stack errors"
else
  fail "t on empty stack does not error"
fi

$(./jp {} .t 2>/dev/null)
if [ $? -ne 0 ];then
  pass "t on non-array errors"
else
  fail "t on non-array does not error"
fi

$(./jp [] .t 2>/dev/null)
if [ $? -ne 0 ];then
  pass "t on empty array errors"
else
  fail "t on empty array does not error"
fi

empty=$(./jp '[1]' .t)
if [ "$empty" = '[]' ];then
  pass 't [1] returns []'
else
  printf -v emptyesc "%q" "$empty"
  fail $"t [1] returns: $emptyesc"
fi

abc=$(./jp '[1,2,3]' .t)
if [ "$abc" = '[2,3]' ];then
  pass 't [1,2,3] returns 1'
else
  printf -v abcesc "%q" "$abc"
  fail $"t [1,2,3] returns: $abcesc"
fi

nest=$(./jp '[4,[1,[2,[3]]]]' .t)
if [ "$nest" = '[[1,[2,[3]]]]' ];then
  pass 't returns nested array'
else
  printf -v nestesc "%q" "$nest"
  fail $"t on nested array returns: $nestesc"
fi

end
