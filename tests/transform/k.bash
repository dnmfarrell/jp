#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .k 2>/dev/null)
if [ $? -ne 0 ];then
  pass "k on empty stack errors"
else
  fail "k on empty stack does not error"
fi

$(./jp '"f"' .k 2>/dev/null)
if [ $? -ne 0 ];then
  pass "k on non-object errors"
else
  fail "k on non-object does not error"
fi

$(./jp {} .k 2>/dev/null)
if [ $? -ne 0 ];then
  pass "k on empty object errors"
else
  fail "k on empty object does not error"
fi

empty=$(./jp '{"":1}' .k)
if [ "$empty" = '""' ];then
  pass "k on empty key returns empty string"
else
  printf -v emptyesc "%q" "$empty"
  fail "k on empty key returns: $emptyesc"
fi

abc=$(./jp '{"abc":1}' .k)
if [ "$abc" = '"abc"' ];then
  pass 'k {"abc":1} returns "abc"'
else
  printf -v abcesc "%q" "$abc"
  fail $"k {\"abc\":1} returns: $abcesc"
fi

end
