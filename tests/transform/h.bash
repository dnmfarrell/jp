#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .h 2>/dev/null)
if [ $? -ne 0 ];then
  pass "h on empty stack errors"
else
  fail "h on empty stack does not error"
fi

$(./jp {} .h 2>/dev/null)
if [ $? -ne 0 ];then
  pass "h on non-array errors"
else
  fail "h on non-array does not error"
fi

$(./jp [] .h 2>/dev/null)
if [ $? -ne 0 ];then
  pass "h on empty array errors"
else
  fail "h on empty array does not error"
fi

empty=$(./jp '["",2,3]' .h)
if [ "$empty" = '""' ];then
  pass $"h on empty string val returns \"\""
else
  printf -v emptyesc "%q" "$empty"
  fail "h on empty string val returns: $emptyesc"
fi

null=$(./jp '[null,2,3]' .h)
if [ "$null" = 'null' ];then
  pass $"h on null val returns null"
else
  printf -v nullesc "%q" "$null"
  fail "h on null val returns: $nullesc"
fi

abc=$(./jp '[1,2,3]' .h)
if [ "$abc" = '1' ];then
  pass 'h [1,2,3] returns 1'
else
  printf -v abcesc "%q" "$abc"
  fail $"h [1,2,3] returns: $abcesc"
fi

nest=$(./jp '[[1,[2,[3]]]]' .h)
if [ "$nest" = '[1,[2,[3]]]' ];then
  pass 'h [1,[2,[3]]] returns 1'
else
  printf -v nestesc "%q" "$nest"
  fail $"h [1,[2,[3]]] returns: $nestesc"
fi

end
