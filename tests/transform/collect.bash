#!/bin/bash
source "test-bootstrap.bash"
IFS=

empty=$(echo 1 | jp .pop .collect)
if [ "$empty" = '[]' ];then
  pass "collect empty stack returns []"
else
  printf -v emptyesc "%q" "$empty"
  fail "collect empty stack returns: $emptyesc"
fi

one=$(echo '"f"' | jp .collect)
if [ "$one" = '["f"]' ];then
  pass 'collect one stack returns ["f"]'
else
  printf -v oneesc "%q" "$one"
  fail "collect one stack returns: $oneesc"
fi

five=$(echo 'false' | jp 'null' 1.5 '{"a":[1,23]}' '[]' .collect)
if [ "$five" = '[[],{"a":[1,23]},1.5,null,false]' ];then
  pass 'collect five stack returns expected'
else
  printf -v fiveesc "%q" "$five"
  fail "collect five stack returns: $fiveesc"
fi

end
