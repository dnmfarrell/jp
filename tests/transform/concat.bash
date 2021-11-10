#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp null .concat 2>/dev/null)
if [ $? -eq 1 ];then
  pass "++ invalid type errors"
else
  fail "++ invalid type does not error"
fi

$(echo '{}' | ./jp '[]' .concat 2>/dev/null)
if [ $? -eq 1 ];then
  pass "++ incompatible collection types errors"
else
  fail "++ incompatible collection types does not error"
fi

$(./jp '{}' '"f"' .concat 2>/dev/null)
if [ $? -eq 1 ];then
  pass "++ incompatible string types errors"
else
  fail "++ incompatible string types does not error"
fi

onestr=$(./jp '"f"' .concat)
if [ "$onestr" = '"f"' ];then
  pass '++ onestr string returns "f"'
else
  printf -v onestresc "%q" "$onestr"
  fail "++ onestr string returns unexpected: $onestresc"
fi

multistr=$(echo '"f "' | ./jp '"bar"' .concat)
if [ "$multistr" = '"barf "' ];then
  pass '++ multistr string returns "barf "'
else
  printf -v multistresc "%q" "$multistr"
  fail "++ multistr string returns unexpected: $multistresc"
fi

emptyarr=$(echo '[]' | ./jp .concat)
if [ "$emptyarr" = '[]' ];then
  pass '++ empty array returns []'
else
  printf -v emptyarresc "%q" "$emptyarr"
  fail "++ empty array returns unexpected: $emptyarresc"
fi

emptymultiarr=$(echo '[]' | ./jp '[]' '[]' .concat)
if [ "$emptyarr" = '[]' ];then
  pass '++ multiple empty array returns []'
else
  printf -v emptyarresc "%q" "$emptyarr"
  fail "++ multiple empty array returns unexpected: $emptyarresc"
fi

onearr=$(echo '[1]' | ./jp .concat)
if [ "$onearr" = '[1]' ];then
  pass '++ one array returns [1]'
else
  printf -v onearresc "%q" "$onearr"
  fail "++ one array returns unexpected: $onearresc"
fi

multiarr=$(echo '[1]' | ./jp '[{"a":1}]' '["foo"]' .concat)
if [ "$multiarr" = '["foo",{"a":1},1]' ];then
  pass '++ multiple arrays return ["foo",{"a":1},1]'
else
  printf -v multiarresc "%q" "$multiarr"
  fail "++ multiple arrays return unexpected: $multiarresc"
fi

emptyobj=$(echo '{}' | ./jp .concat)
if [ "$emptyobj" = '{}' ];then
  pass '++ empty object returns {}'
else
  printf -v emptyobjesc "%q" "$emptyobj"
  fail "++ empty object returns unexpected: $emptyobjesc"
fi

emptymultiobj=$(echo '{}' | ./jp '{}' '{}' .concat)
if [ "$emptyobj" = '{}' ];then
  pass '++ multiple empty object returns {}'
else
  printf -v emptyobjesc "%q" "$emptyobj"
  fail "++ multiple empty object returns unexpected: $emptyobjesc"
fi

oneobj=$(echo '{"A":1}' | ./jp .concat)
if [ "$oneobj" = '{"A":1}' ];then
  pass '++ one object returns {"A":1}'
else
  printf -v oneobjesc "%q" "$oneobj"
  fail "++ one object returns unexpected: $oneobjesc"
fi

multiobj=$(echo '{"b":false}' | ./jp '{"a":[1]}' '{"foo":5}' .concat)
if [ "$multiobj" = '{"foo":5,"a":[1],"b":false}' ];then
  pass '++ multiple objects return {"foo":5,"a":[1],"b":false}'
else
  printf -v multiobjesc "%q" "$multiobj"
  fail "++ multiple objects return unexpected: $multiobjesc"
fi

end
