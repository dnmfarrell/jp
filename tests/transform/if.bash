#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .if 2>/dev/null)
if [ $? -eq 1 ];then
  pass "if empty stack errors"
else
  fail "if empty stack does not error"
fi

$(./jp null .if 2>/dev/null)
if [ $? -eq 1 ];then
  pass "if illegal operand type errors"
else
  fail "if illegal operand type does not error"
fi

t=$(./jp 'true' .if 1)
if [ "$t" = '1' ];then
  pass "true if 1 returns 1"
else
  printf -v tesc "%q" "$t"
  fail "true if 1 returns: $tesc"
fi

f=$(./jp 'false' .if 1)
if [ "$f" = '' ];then
  pass "false if 1 returns empty string"
else
  printf -v fesc "%q" "$f"
  fail "false if 1 returns: $fesc"
fi
