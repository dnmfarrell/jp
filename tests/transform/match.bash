#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .match 2>/dev/null)
if [ $? -eq 1 ];then
  pass "match empty stack errors"
else
  fail "match empty stack does not error"
fi

$(./jp null .match 2>/dev/null)
if [ $? -eq 1 ];then
  pass "match illegal operand type errors"
else
  fail "match illegal operand type does not error"
fi

$(./jp '{}' '"*"' .match 2>/dev/null)
if [ $? -eq 1 ];then
  pass "match illegal type errors"
else
  fail "match illegal type does not error"
fi

nothing=$(./jp '"1"' .match)
if [ "$nothing" = '[]' ];then
  pass "match one stack returns []"
else
  printf -v nothingesc "%q" "$nothing"
  fail "match one stack returns: $nothingesc"
fi

none=$(./jp 1 2 3 5 '"a"' .match)
if [ "$none" = '[]' ];then
  pass "match no true cases returns []"
else
  printf -v noneesc "%q" "$none"
  fail "match no true cases returns: $noneesc"
fi

one=$(./jp 1 2 3 5 '"3"' .match)
if [ "$one" = '[3]' ];then
  pass "match one item"
else
  printf -v oneesc "%q" "$one"
  fail "match one item returns: $oneesc"
fi

strnum=$(./jp 1 '"ded mau5"' '"[0-9]$"' .match)
if [ "$strnum" = '["ded mau5",1]' ];then
  pass "match str and num"
else
  printf -v strnumesc "%q" "$strnum"
  fail "match str and num: $strnumesc"
fi

multi=$(./jp '"anon"' '"a bar"' '"a fish"' '"^a "' .match)
if [ "$multi" = '["a fish","a bar"]' ];then
  pass "match multi item"
else
  printf -v multiesc "%q" "$multi"
  fail "match multi item returns: $multiesc"
fi

emptystr=$(./jp '""' '" bar"' '"a "' '"^$"' .match)
if [ "$emptystr" = '[""]' ];then
  pass "match emptystr item"
else
  printf -v emptystresc "%q" "$emptystr"
  fail "match emptystr item returns: $emptystresc"
fi

end
