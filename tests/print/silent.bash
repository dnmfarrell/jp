#!/bin/bash
source "test-bootstrap.bash"
IFS=

empty=$(jp -ns)
if [ "$empty" = '' ];then
  pass "silent mode emits nothing with empty stack"
else
  printf -v emptyesc "%q" "$empty"
  fail "silent mode emits nothing with empty stack: $emptyesc"
fi

arrays=$(cat tests/share/arrays.jsonp | jp -s)
if [ "$arrays" = '' ];then
  pass "silent mode emits nothing with arrays stack"
else
  printf -v arraysesc "%q" "$arrays"
  fail "silent mode emits nothing with arrays stack: $arraysesc"
fi

end
