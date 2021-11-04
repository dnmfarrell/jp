#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(echo 1 | jp .pop .i 2>/dev/null)
if [ $? -eq 1 ];then
  pass "i on empty stack errors"
else
  fail "i on empty stack does not error"
fi

$(echo 1 | jp '[]' 1 .i 2>/dev/null)
if [ $? -eq 1 ];then
  pass "i on non-array stack errors"
else
  fail "i on non-array stack does not error"
fi

$(echo '[]' | jp null .i 2>/dev/null)
if [ $? -eq 1 ];then
  pass "i non-integer errors"
else
  fail "i non-integer does not error"
fi

empty=$(echo '[]' | jp 1 .i)
if [ "$empty" = '[]' ];then
  pass "i on empty array returns []"
else
  printf -v emptyesc "%q" "$empty"
  fail "i on empty array doesn't return []: $emptyesc"
fi

larger=$(echo '[1]' | jp 1 .i)
if [ "$larger" = '[]' ];then
  pass "i larger than array returns []"
else
  printf -v largeresc "%q" "$larger"
  fail "i larger than array doesn't return []: $largeresc"
fi

onematch=$(echo '[0,1]' | jp 1 .i)
if [ "$onematch" = '[1]' ];then
  pass "i one match returns expected"
else
  printf -v onematchesc "%q" "$onematch"
  fail "i on unmatched doesn't return expected: $onematchesc"
fi

multimatch=$(echo '[true,{"a":1}]' | jp '[null]' '[1,[]]' 1 .i)
if [ "$multimatch" = '[[],{"a":1}]' ];then
  pass "i multi match returns expected"
else
  printf -v multimatchesc "%q" "$multimatch"
  fail "i on unmatched doesn't return expected: $multimatchesc"
fi

end
