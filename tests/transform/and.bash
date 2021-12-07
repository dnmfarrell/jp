#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .and 2>/dev/null)
if [ $? -eq 1 ];then
  pass "and empty stack errors"
else
  fail "and empty stack does not error"
fi

$(./jp true .and 2>/dev/null)
if [ $? -eq 1 ];then
  pass "and missing right operand errors"
else
  fail "and missing right operand does not error"
fi

$(./jp null .and 2>/dev/null)
if [ $? -eq 1 ];then
  pass "and illegal left operand errors"
else
  fail "and illegal left operand does not error"
fi

$(./jp false null .and 2>/dev/null)
if [ $? -eq 1 ];then
  pass "and illegal right operand errors"
else
  fail "and illegal right operand does not error"
fi

tt=$(./jp true true .and)
if [ "$tt" = 'true' ];then
  pass "and true true returns true"
else
  printf -v ttesc "%q" "$tt"
  fail "and true true returns: $ttesc"
fi

tf=$(./jp true false .and)
if [ "$tf" = 'false' ];then
  pass "and true false returns false"
else
  printf -v tfesc "%q" "$tf"
  fail "and true false returns: $tfesc"
fi

ft=$(./jp false true .and)
if [ "$ft" = 'false' ];then
  pass "and false true returns false"
else
  printf -v ftesc "%q" "$ft"
  fail "and false true returns: $ftesc"
fi

ff=$(./jp false false .and)
if [ "$ff" = 'false' ];then
  pass "and false false returns false"
else
  printf -v ffesc "%q" "$ff"
  fail "and false false returns: $ffesc"
fi

end
