#!/bin/bash
source "test-bootstrap.bash"

empty=$(./jp .pop 2>/dev/null)
if [ $? -ne 0 ];then
  pass "pop empty stack errors"
else
  fail "pop empty stack does not error"
fi

popone=$(./jp '{"a":1}' .pop)
if [ "$popone" = '' ];then
  pass "pop popone"
else
  printf -v poponeesc "%q" "$popone"
  fail "pop popone: got $poponeesc"
fi

poptwo=$(./jp 1 '{}' '[]' .pop .pop)
if [ "$poptwo" = '1' ];then
  pass "pop poptwo"
else
  printf -v poptwoesc "%q" "$poptwo"
  fail "pop poptwo: got $poptwoesc"
fi

end
