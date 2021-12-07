#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .exists 2>/dev/null)
if [ $? -eq 1 ];then
  pass "exists on empty stack errors"
else
  fail "exists on empty stack does not error"
fi

$(./jp {} 1 .exists 2>/dev/null)
if [ $? -eq 1 ];then
  pass "exists on non-string stack errors"
else
  fail "exists on non-string stack does not error"
fi

$(./jp 1 '"f"' .exists 2>/dev/null)
if [ $? -eq 1 ];then
  pass "exists on non-object stack errors"
else
  fail "exists on non-object stack does not error"
fi

empty=$(./jp '{}' '"foo"' .exists)
if [ "$empty" = $'false\n{}' ];then
  pass "exists on empty object returns false"
else
  printf -v emptyesc "%q" "$empty"
  fail "exists on empty object doesn't return false: $emptyesc"
fi

first=$(./jp '{"a":1,"b":2}' '"a"' .exists)
if [ "$first" = $'true\n{"a":1,"b":2}' ];then
  pass "exists matches first key in object"
else
  printf -v firstesc "%q" "$first"
  fail "exists doesn't match first key in object: $firstesc"
fi

last=$(./jp '{"a":1,"b":2}' '"b"' .exists)
if [ "$last" = $'true\n{"a":1,"b":2}' ];then
  pass "exists matches last key in object"
else
  printf -v lastesc "%q" "$last"
  fail "exists doesn't match last key in object: $lastesc"
fi

zero=$(./jp '{"":1}' '""' .exists)
if [ "$zero" = $'true\n{"":1}' ];then
  pass "exists matches empty string"
else
  printf -v zeroesc "%q" "$zero"
  fail "exists doesn't match empty string: $zeroesc"
fi

end
