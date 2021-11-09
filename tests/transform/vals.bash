#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .vals 2>/dev/null)
if [ $? -eq 1 ];then
  pass "vals on empty stack errors"
else
  fail "vals on empty stack does not error"
fi

$(echo 1 | ./jp .vals 2>/dev/null)
if [ $? -eq 1 ];then
  pass "vals on non-object stack errors"
else
  fail "vals on non-object stack does not error"
fi

emptyobj=$(echo '{}' | ./jp .vals)
if [ "$emptyobj" = '' ];then
  pass "vals on empty object returns nothing"
else
  printf -v emptyobjesc "%q" "$emptyobj"
  fail "vals on empty object doesn't return nothing: $emptyobjesc"
fi

twoobj=$(echo '{"a":1,"b":2}' | ./jp .vals)
if [ "$twoobj" = $'2\n1' ];then
  pass "vals on object returns two vals"
else
  printf -v twoobjesc "%q" "$twoobj"
  fail "vals on object doesn't return two vals: $twoobjesc"
fi

nestobj=$(./jp '{"a":[null,"1",{" a b ":[" a b "]}],"c":2}' .vals)
if [ "$nestobj" = $'2\n[null,"1",{" a b ":[" a b "]}]' ];then
  pass "vals on nested object returns expected"
else
  printf -v nestobjesc "%q" "$nestobj"
  fail "vals on nested object doesn't return expected: $nestobjesc"
fi

emptyarr=$(echo '[]' | ./jp .vals)
if [ "$emptyarr" = '' ];then
  pass "vals on empty arrect returns nothing"
else
  printf -v emptyarresc "%q" "$emptyarr"
  fail "vals on empty arrect doesn't return nothing: $emptyarresc"
fi

twoarr=$(echo '[1,2]' | ./jp .vals)
if [ "$twoarr" = $'2\n1' ];then
  pass "vals on array returns two vals"
else
  printf -v twoarresc "%q" "$twoarr"
  fail "vals on array doesn't return two vals: $twoarresc"
fi

nestarr=$(./jp '[["a"],true,[[{"b":1}],null]]' .vals)
if [ "$nestarr" = $'[[{"b":1}],null]\ntrue\n["a"]' ];then
  pass "vals on nested array returns expected"
else
  printf -v nestedesc "%q" "$nestarr"
  fail "vals on nested array doesn't return expected: $nestarresc"
fi

end
