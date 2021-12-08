#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .if 2>/dev/null)
if [ $? -ne 0 ];then
  pass "if empty stack errors"
else
  fail "if empty stack does not error"
fi

$(./jp null .if 2>/dev/null)
if [ $? -ne 0 ];then
  pass "if illegal operand type errors"
else
  fail "if illegal operand type does not error"
fi

$(./jp .else 2>/dev/null)
if [ $? -ne 0 ];then
  pass "naked else errors"
else
  fail "naked else does not error"
fi

t=$(./jp 'true' .if 1)
if [ "$t" = '1' ];then
  pass "true if 1 returns 1"
else
  printf -v tesc "%q" "$t"
  fail "true if 1 returns: $tesc"
fi

te=$(./jp 'true' .if 1 .else 2)
if [ "$te" = '1' ];then
  pass "true if 1 ... else returns 1"
else
  printf -v teesc "%q" "$te"
  fail "true if 1 ... else returns: $teesc"
fi

ted=$(./jp 'true' .if .do 1 .done .else .do 2 .done)
if [ "$ted" = '1' ];then
  pass "true if .do 1 ... else returns 1"
else
  printf -v tedesc "%q" "$ted"
  fail "true if 1 .do ... else returns: $tedesc"
fi

f=$(./jp 'false' .if 1)
if [ "$f" = '' ];then
  pass "false if 1 returns empty string"
else
  printf -v fesc "%q" "$f"
  fail "false if 1 returns: $fesc"
fi

fe=$(./jp 'false' .if 1 .else 2)
if [ "$fe" = '2' ];then
  pass "false if ... else 2 returns 2"
else
  printf -v feesc "%q" "$fe"
  fail "false if ... else 2 returns: $feesc"
fi

fed=$(./jp 'false' .if .do 1 .done .else .do 2 .done)
if [ "$fed" = '2' ];then
  pass "false if ... else .do 2 .done returns 2"
else
  printf -v fedesc "%q" "$fed"
  fail "false if ... else .do 2 .done returns: $fedesc"
fi

end
