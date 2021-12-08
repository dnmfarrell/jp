#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .match 2>/dev/null)
if [ $? -ne 0 ];then
  pass "match empty stack errors"
else
  fail "match empty stack does not error"
fi

$(./jp '"*"' .match 2>/dev/null)
if [ $? -ne 0 ];then
  pass "match missing right operand errors"
else
  fail "match missing right operand does not error"
fi

$(./jp null .match 2>/dev/null)
if [ $? -ne 0 ];then
  pass "match illegal operand type errors"
else
  fail "match illegal operand type does not error"
fi

$(./jp '{}' '"*"' .match 2>/dev/null)
if [ $? -ne 0 ];then
  pass "match illegal type errors"
else
  fail "match illegal type does not error"
fi

strmatch=$(./jp '"f"' '"[a-z]"' .match)
if [ "$strmatch" = 'true' ];then
  pass "match f [a-z] returns true"
else
  printf -v strmatchesc "%q" "$strmatch"
  fail "match f [a-z] returns: $strmatchesc"
fi

strdiff=$(./jp '""' '"[A-Z]"' .match)
if [ "$strdiff" = 'false' ];then
  pass "match '' [A-Z] returns false"
else
  printf -v strdiffesc "%q" "$strdiff"
  fail "match '' [A-Z] returns: $strdiffesc"
fi

intmatch=$(./jp 17 '"[0-9]+"' .match)
if [ "$intmatch" = 'true' ];then
  pass "match 17 [0-9]+ returns true"
else
  printf -v intmatchesc "%q" "$intmatch"
  fail "match 17 [0-9]+ returns: $intmatchesc"
fi

intdiff=$(./jp 5 '"[a-z]"' .match)
if [ "$intdiff" = 'false' ];then
  pass "match 5 [a-z] returns false"
else
  printf -v intdiffesc "%q" "$intdiff"
  fail "match 5 [a-z] returns: $intdiffesc"
fi

end
