#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .v 2>/dev/null)
if [ $? -eq 1 ];then
  pass "v on empty stack errors"
else
  fail "v on empty stack does not error"
fi

$(./jp '"f"' .v 2>/dev/null)
if [ $? -eq 1 ];then
  pass "v on non-object errors"
else
  fail "v on non-object does not error"
fi

$(./jp {} .v 2>/dev/null)
if [ $? -eq 1 ];then
  pass "v on empty object errors"
else
  fail "v on empty object does not error"
fi

empty=$(./jp '{"foo":""}' .v)
if [ "$empty" = '""' ];then
  pass $"v on empty string val returns \"\""
else
  printf -v emptyesc "%q" "$empty"
  fail "v on empty string val returns: $emptyesc"
fi

null=$(./jp '{"foo":null}' .v)
if [ "$null" = 'null' ];then
  pass $"v on null val returns null"
else
  printf -v nullesc "%q" "$null"
  fail "v on null val returns: $nullesc"
fi

abc=$(./jp '{"abc":1}' .v)
if [ "$abc" = '1' ];then
  pass 'v {"abc":1} returns 1'
else
  printf -v abcesc "%q" "$abc"
  fail $"v {\"abc\":1} returns: $abcesc"
fi

end
