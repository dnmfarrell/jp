#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .idx 2>/dev/null)
if [ $? -ne 0 ];then
  pass "idx errors on missing both args"
else
  fail "idx errors on missing both args"
fi
$(./jp 1 .idx 2>/dev/null)
if [ $? -ne 0 ];then
  pass "idx errors missing 1 arg"
else
  fail "idx errors missing 1 arg"
fi
$(./jp [] -1 .idx 2>/dev/null)
if [ $? -ne 0 ];then
  pass "idx errors negative index"
else
  fail "idx errors negative index"
fi
$(./jp [] true .idx 2>/dev/null)
if [ $? -ne 0 ];then
  pass "idx errors wrong 1st arg type"
else
  fail "idx errors wrong 1st arg type"
fi
$(./jp  {} 0 .idx 2>/dev/null)
if [ $? -ne 0 ];then
  pass "idx errors wrong 2nd arg type"
else
  fail "idx errors wrong 2nd arg type"
fi
empty=$(./jp [] 0 .idx)
if [ "$empty" = '' ];then
  pass "empty array returns nothing"
else
  printf -v emptyesc "%q" "$empty"
  fail "empty array returns nothing: $emptyesc"
fi
gtr=$(./jp [0] 1 .idx)
if [ "$gtr" = '' ];then
  pass "idx greater than array len returns nothing"
else
  printf -v gtresc "%q" "$gtr"
  fail "idx greater than array len returns nothing $gtresc"
fi
zeroth=$(./jp '["foo","bar","baz"]' 0 .idx)
if [ "$zeroth" = '"foo"' ];then
  pass "zeroth element matches \"foo\""
else
  printf -v zerothesc "%q" "$zeroth"
  fail "zeroth element matches \"foo\": $zerothesc"
fi
last=$(./jp '["foo","bar","baz"]' 2 .idx)
if [ "$last" = '"baz"' ];then
  pass "last element is \"baz\""
else
  printf -v lastesc "%q" "$last"
  fail "last element is \"baz\": $lastesc"
fi
nest=$(./jp '["foo",[1,2,3,4,5],"baz"]' 1 .idx)
if [ "$nest" = '[1,2,3,4,5]' ];then
  pass "got nested array"
else
  printf -v nestesc "%q" "$nest"
  fail "got nested array: $nestesc"
fi

end
