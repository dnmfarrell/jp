#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp -m macros.jp .not 2>/dev/null)
if [ $? -ne 0 ];then
  pass "not empty stack errors"
else
  fail "not empty stack does not error"
fi

$(./jp -m macros.jp null .not 2>/dev/null)
if [ $? -ne 0 ];then
  pass "not illegal operand type errors"
else
  fail "not illegal operand type does not error"
fi

t=$(./jp -m macros.jp 'true' .not)
if [ "$t" = 'false' ];then
  pass "true not returns false"
else
  printf -v tesc "%q" "$t"
  fail "true not returns: $tesc"
fi

f=$(./jp -m macros.jp 'false' .not)
if [ "$f" = 'true' ];then
  pass "false not returns true"
else
  printf -v fesc "%q" "$f"
  fail "false not returns: $fesc"
fi

end
