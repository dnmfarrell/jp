#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .keyval 2>/dev/null)
if [ $? -ne 0 ];then
  pass "keyval errors on missing both args"
else
  fail "keyval errors on missing both args"
fi
$(./jp '""' .keyval 2>/dev/null)
if [ $? -ne 0 ];then
  pass "keyval errors missing 1 arg"
else
  fail "keyval errors missing 1 arg"
fi
$(./jp {} true .keyval 2>/dev/null)
if [ $? -ne 0 ];then
  pass "keyval errors wrong 1st arg type"
else
  fail "keyval errors wrong 1st arg type"
fi
$(./jp  [] '""' .keyval 2>/dev/null)
if [ $? -ne 0 ];then
  pass "keyval errors wrong 2nd arg type"
else
  fail "keyval errors wrong 2nd arg type"
fi
empty=$(./jp {} '"f"' .keyval)
if [ "$empty" = '' ];then
  pass "empty object  returns nothing"
else
  printf -v emptyesc "%q" "$empty"
  fail "empty object returns nothing: $emptyesc"
fi
nomatch=$(./jp '{"f":1}' '"g"' .keyval)
if [ "$nomatch" = '' ];then
  pass "keyval unmatched key returns nothing"
else
  printf -v nomatchesc "%q" "$nomatch"
  fail "keyval unmatched key returns nothing $nomatchesc"
fi
first=$(./jp '{"foo":1,"bar":2,"baz":3}' '"foo"' .keyval)
if [ "$first" = '1' ];then
  pass "first element is 1"
else
  printf -v firstesc "%q" "$first"
  fail "first element is 1: $firstesc"
fi
last=$(./jp '{"foo":1,"bar":2,"baz":3}' '"baz"' .keyval)
if [ "$last" = '3' ];then
  pass "last element is 3"
else
  printf -v lastesc "%q" "$last"
  fail "last element is 3: $lastesc"
fi
nest=$(./jp '{"foo":1,"bar":{"a":2,"b":[1,2,3]},"baz":3}' '"bar"' .keyval)
if [ "$nest" = '{"a":2,"b":[1,2,3]}' ];then
  pass "got nested object"
else
  printf -v nestesc "%q" "$nest"
  fail "got nested object: $nestesc"
fi

end
