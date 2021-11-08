#!/bin/bash
source "test-bootstrap.bash"
IFS=

empty=$(./jp .collect)
if [ "$empty" = '[]' ];then
  pass "collect empty stack returns []"
else
  printf -v emptyesc "%q" "$empty"
  fail "collect empty stack returns: $emptyesc"
fi

one=$(./jp '" foo bar "' .collect)
if [ "$one" = '[" foo bar "]' ];then
  pass 'collect one stack returns ["f"]'
else
  printf -v oneesc "%q" "$one"
  fail "collect one stack returns: $oneesc"
fi

five=$(./jp 'false' null 1.5 '{"a b ":[1,23]}' '[]' .collect)
if [ "$five" = '[[],{"a b ":[1,23]},1.5,null,false]' ];then
  pass 'collect five stack returns expected'
else
  printf -v fiveesc "%q" "$five"
  fail "collect five stack returns: $fiveesc"
fi

end
