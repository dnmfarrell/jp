#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .keys 2>/dev/null)
if [ $? -eq 1 ];then
  pass "keys on empty stack errors"
else
  fail "keys on empty stack does not error"
fi

$(echo 1 | ./jp .keys 2>/dev/null)
if [ $? -eq 1 ];then
  pass "keys on non-object stack errors"
else
  fail "keys on non-object stack does not error"
fi

empty=$(./jp '{}' .keys)
if [ "$empty" = '' ];then
  pass "keys on empty returns nothing"
else
  printf -v emptyesc "%q" "$empty"
  fail "keys on empty doesn't return nothing: $emptyesc"
fi

two=$(./jp '{" a b c ":1,"b":2}' .keys)
if [ "$two" = $'"b"\n" a b c "' ];then
  pass "keys returns two strings"
else
  printf -v twoesc "%q" "$two"
  fail "keys doesn't return two strings: $twoesc"
fi

end
