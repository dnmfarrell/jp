#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .pairs 2>/dev/null)
if [ $? -eq 1 ];then
  pass "pairs on empty stack errors"
else
  fail "pairs on empty stack does not error"
fi

$(echo 1 | ./jp .pairs 2>/dev/null)
if [ $? -eq 1 ];then
  pass "pairs on non-object stack errors"
else
  fail "pairs on non-object stack does not error"
fi

emptyobj=$(echo '{}' | ./jp .pairs)
if [ "$emptyobj" = '' ];then
  pass "pairs on empty object returns nothing"
else
  printf -v emptyobjesc "%q" "$emptyobj"
  fail "pairs on empty object doesn't return empty:"
fi

twoobj=$(./jp '{"a":1," b c ":2}' .pairs)
if [ "$twoobj" = $'{" b c ":2}\n{"a":1}' ];then
  pass "pairs on object returns two pairs"
else
  printf -v twoobjesc "%q" "$twoobj"
  fail "pairs on object doesn't return two pairs: $twoobjesc"
fi

nestobj=$(echo '{"a":[null,"1",{" b c ":[1]}],"c":2}' | ./jp .pairs)
if [ "$nestobj" = $'{"c":2}\n{"a":[null,"1",{" b c ":[1]}]}' ];then
  pass "pairs on nested object returns expected"
else
  printf -v nestobjesc "%q" "$nestobj"
  fail "pairs on nested object doesn't return expected: $nestobjesc"
fi

end
