#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .uniq 2>/dev/null)
if [ $? -ne 0 ];then
  pass "uniq on empty stack errors"
else
  fail "uniq on empty stack does not error"
fi

$(./jp 1 .uniq 2>/dev/null)
if [ $? -ne 0 ];then
  pass "uniq on non-object stack errors"
else
  fail "uniq on non-object stack does not error"
fi

empty=$(./jp '{}' .uniq)
if [ "$empty" = '{}' ];then
  pass "uniq on empty returns {}"
else
  printf -v emptyesc "%q" "$empty"
  fail "uniq on empty doesn't return nothing: $emptyesc"
fi

two=$(./jp '{" a b c ":1,"b":2, " a b c ":3}' .uniq)
if [ "$two" = $'{" a b c ":1,"b":2}' ];then
  pass "uniq returns two strings"
else
  printf -v twoesc "%q" "$two"
  fail "uniq doesn't return two strings: $twoesc"
fi

cases=$(./jp '{"FOO":1,"foo":2}' .uniq)
if [ "$cases" = $'{"FOO":1,"foo":2}' ];then
  pass "uniq ignores different case strings"
else
  printf -v casesesc "%q" "$cases"
  fail "uniq doesn't ignore different case strings: $casesesc"
fi

end
