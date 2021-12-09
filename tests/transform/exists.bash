#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp -m macros.jp .exists 2>/dev/null)
if [ $? -ne 0 ];then
  pass "exists on empty stack errors"
else
  fail "exists on empty stack does not error"
fi

$(./jp -m macros.jp {} 1 .exists 2>/dev/null)
if [ $? -ne 0 ];then
  pass "exists on non-string stack errors"
else
  fail "exists on non-string stack does not error"
fi

$(./jp -m macros.jp 1 '"f"' .exists 2>/dev/null)
if [ $? -ne 0 ];then
  pass "exists on non-object stack errors"
else
  fail "exists on non-object stack does not error"
fi

empty=$(./jp -m macros.jp '{}' '"foo"' .exists)
if [ "$empty" = $'false' ];then
  pass "exists on empty object returns false"
else
  printf -v emptyesc "%q" "$empty"
  fail "exists on empty object doesn't return false: $emptyesc"
fi

first=$(./jp -m macros.jp '{"a":1,"b":2}' '"a"' .exists)
if [ "$first" = $'true' ];then
  pass "exists matches first key in object"
else
  printf -v firstesc "%q" "$first"
  fail "exists doesn't match first key in object: $firstesc"
fi

last=$(./jp -m macros.jp '{"a":1,"b":2}' '"b"' .exists)
if [ "$last" = $'true' ];then
  pass "exists matches last key in object"
else
  printf -v lastesc "%q" "$last"
  fail "exists doesn't match last key in object: $lastesc"
fi

zero=$(./jp -m macros.jp '{"":1}' '""' .exists)
if [ "$zero" = $'true' ];then
  pass "exists matches empty string"
else
  printf -v zeroesc "%q" "$zero"
  fail "exists doesn't match empty string: $zeroesc"
fi

end
