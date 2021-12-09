#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp -m macros.jp .or 2>/dev/null)
if [ $? -ne 0 ];then
  pass "or empty stack errors"
else
  fail "or empty stack does not error"
fi

$(./jp -m macros.jp true .or 2>/dev/null)
if [ $? -ne 0 ];then
  pass "or missing right operand errors"
else
  fail "or missing right operand does not error"
fi

$(./jp -m macros.jp null .or 2>/dev/null)
if [ $? -ne 0 ];then
  pass "or illegal left operand errors"
else
  fail "or illegal left operand does not error"
fi

$(./jp -m macros.jp false null .or 2>/dev/null)
if [ $? -ne 0 ];then
  pass "or illegal right operand errors"
else
  fail "or illegal right operand does not error"
fi

tt=$(./jp -m macros.jp true true .or)
if [ "$tt" = 'true' ];then
  pass "or true true returns true"
else
  printf -v ttesc "%q" "$tt"
  fail "or true true returns: $ttesc"
fi

tf=$(./jp -m macros.jp true false .or)
if [ "$tf" = 'true' ];then
  pass "or true false returns true"
else
  printf -v tfesc "%q" "$tf"
  fail "or true false returns: $tfesc"
fi

ft=$(./jp -m macros.jp false true .or)
if [ "$ft" = 'true' ];then
  pass "or false true returns true"
else
  printf -v ftesc "%q" "$ft"
  fail "or false true returns: $ftesc"
fi

ff=$(./jp -m macros.jp false false .or)
if [ "$ff" = 'false' ];then
  pass "or false false returns false"
else
  printf -v ffesc "%q" "$ff"
  fail "or false false returns: $ffesc"
fi

end
