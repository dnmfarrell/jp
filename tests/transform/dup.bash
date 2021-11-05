#!/bin/bash
source "test-bootstrap.bash"
IFS=

empty=$(./jp .dup 2>/dev/null)
if [ $? -eq 1 ];then
  pass "dup empty stack errors"
else
  fail "dup empty stack does not error"
fi

once=$(./jp [1] .dup)
if [ "$once" = $'[1]\n[1]' ];then
  pass "dup once"
else
  printf -v onceesc "%q" "$once"
  fail "dup once: got $onceesc"
fi

twice=$(./jp '[" a b c "]' .dup .dup)
if [ "$twice" = $'[" a b c "]\n[" a b c "]\n[" a b c "]' ];then
  pass "dup twice"
else
  printf -v twiceesc "%q" "$twice"
  fail "dup twice: got $twiceesc"
fi

two=$(./jp 'true' 'false' .dup)
if [ "$two" = $'false\nfalse\ntrue' ];then
  pass "dup two stack"
else
  printf -v twoesc "%q" "$two"
  fail "dup two stack: got $twoesc"
fi

end
