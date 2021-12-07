#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test empty stack errors"
else
  fail "test empty stack does not error"
fi

$(./jp 1 .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test missing right operand errors"
else
  fail "test missing right operand does not error"
fi

$(./jp null null .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test illegal operand type errors"
else
  fail "test illegal operand type does not error"
fi

$(./jp 1 '"f"' .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test mismatched types errors"
else
  fail "test mismatched types does not error"
fi

$(./jp '"f"' 1 .eq 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test mismatched types errors"
else
  fail "test mismatched types does not error"
fi

$(./jp '"f"' '"f"' .ge 2>/dev/null)
if [ $? -eq 1 ];then
  pass "test invalid string op errors"
else
  fail "test invalid string op does not error"
fi

strmatch=$(./jp '"f"' '"f"' .eq)
if [ "$strmatch" = 'true' ];then
  pass "test matching strings returns true"
else
  printf -v strmatchesc "%q" "$strmatch"
  fail "test matching strings returns: $strmatchesc"
fi

strdiff=$(./jp '"f"' '"a"' .eq)
if [ "$strdiff" = 'false' ];then
  pass "test different strings returns false"
else
  printf -v strdiffesc "%q" "$strdiff"
  fail "test different strings returns: $strdiffesc"
fi

intmatch=$(./jp 17 17 .eq)
if [ "$intmatch" = 'true' ];then
  pass "test matching ints returns true"
else
  printf -v intmatchesc "%q" "$intmatch"
  fail "test matching ints returns: $intmatchesc"
fi

intdiff=$(./jp 5 43 .eq)
if [ "$intdiff" = 'false' ];then
  pass "test different ints returns false"
else
  printf -v intdiffesc "%q" "$intdiff"
  fail "test different ints returns: $intdiffesc"
fi

end
