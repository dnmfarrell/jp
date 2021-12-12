#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp null .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat invalid type errors"
else
  fail "concat invalid type does not error"
fi

$(./jp '{}' '[]' .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat incompatible collection types errors"
else
  fail "concat incompatible collection types does not error"
fi

$(./jp '{}' '"f"' .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat incompatible string types errors"
else
  fail "concat incompatible string types does not error"
fi

$(./jp '"f"' .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat one string errors"
else
  fail "concat one string does not error"
fi

$(./jp [1] .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat one array errors"
else
  fail "concat one array does not error"
fi

$(./jp '{"a":1}' .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat one object errors"
else
  fail "concat one object does not error"
fi

$(./jp '"f"' .concat 2>/dev/null)
if [ $? -ne 0 ];then
  pass "concat one string errors"
else
  fail "concat one string does not error"
fi

str=$(echo '"f "' | ./jp '"bar"' .concat)
if [ "$str" = '"barf "' ];then
  pass 'concat str string returns "barf "'
else
  printf -v stresc "%q" "$str"
  fail "concat str string returns unexpected: $stresc"
fi

emptyarr=$(./jp [] [] .concat)
if [ "$emptyarr" = '[]' ];then
  pass 'concat empty arrays returns []'
else
  printf -v emptyarresc "%q" "$emptyarr"
  fail "concat empty arrays returns unexpected: $emptyarresc"
fi

emptyarr=$(./jp '[]' '["foo"]' .concat)
if [ "$emptyarr" = '["foo"]' ];then
  pass 'concat one array with empty returns ["foo"]'
else
  printf -v emptyesc "%q" "$emptyarr"
  fail "concat one array with empty return: $emptyesc"
fi

arr=$(./jp '[{"a":1}]' '["foo"]' .concat)
if [ "$arr" = '["foo",{"a":1}]' ];then
  pass 'concat arrays return ["foo",{"a":1},1]'
else
  printf -v arresc "%q" "$arr"
  fail "concat arrays return unexpected: $arresc"
fi

emptyobj=$(./jp '{}' '{}' .concat)
if [ "$emptyobj" = '{}' ];then
  pass 'concat empty objects returns {}'
else
  printf -v emptyobjesc "%q" "$emptyobj"
  fail "concat empty objects returns unexpected: $emptyobjesc"
fi

oneobj=$(./jp '{"A":1}' {} .concat)
if [ "$oneobj" = '{"A":1}' ];then
  pass 'concat one object with empty returns {"A":1}'
else
  printf -v oneobjesc "%q" "$oneobj"
  fail "concat one object with empty returns unexpected: $oneobjesc"
fi

obj=$(./jp '{"a":[1]}' '{"foo":5}' .concat)
if [ "$obj" = '{"foo":5,"a":[1]}' ];then
  pass 'concat objects return {"foo":5,"a":[1]}'
else
  printf -v objesc "%q" "$obj"
  fail "concat objects return unexpected: $objesc"
fi

end
