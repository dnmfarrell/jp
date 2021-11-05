#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .k 2>/dev/null)
if [ $? -eq 1 ];then
  pass "k on empty stack errors"
else
  fail "k on empty stack does not error"
fi

$(echo 1 | ./jp {} "f" .k 2>/dev/null)
if [ $? -eq 1 ];then
  pass "k on non-object stack errors"
else
  fail "k on non-object stack does not error"
fi

$(echo 1 | ./jp .k 2>/dev/null)
if [ $? -eq 1 ];then
  pass "k non-string key errors"
else
  fail "k non-string key does not error"
fi

empty=$(echo '{}' | ./jp '"f"' .k)
if [ "$empty" = '[]' ];then
  pass "k on empty object returns []"
else
  printf -v emptyesc "%q" "$empty"
  fail "k on empty object doesn't return []: $emptyesc"
fi

nomatch=$(echo '{"a":1}' | ./jp '"f"' .k)
if [ "$nomatch" = '[]' ];then
  pass "k unmatched returns []"
else
  printf -v nomatchesc "%q" "$nomatch"
  fail "k on unmatched doesn't return []: $nomatchesc"
fi

onematch=$(./jp '{" a":1}' '{" a ":2}' '" a"' .k)
if [ "$onematch" = '[1]' ];then
  pass "k one match returns expected"
else
  printf -v onematchesc "%q" "$onematch"
  fail "k on unmatched doesn't return expected: $onematchesc"
fi

multimatch=$(echo '{"a":1,"a":2}' | ./jp '{"a":3}' '"a"' .k)
if [ "$multimatch" = '[3,1,2]' ];then
  pass "k multi match returns expected"
else
  printf -v multimatchesc "%q" "$multimatch"
  fail "k on unmatched doesn't return expected: $multimatchesc"
fi

end
