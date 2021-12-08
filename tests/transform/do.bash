#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp .do 2>/dev/null)
if [ $? -eq 1 ];then
  pass "unterminated do errors"
else
  fail "unterminated do does not error"
fi

$(./jp .done 2>/dev/null)
if [ $? -ne 0 ];then
  pass "naked done errors"
else
  fail "naked done does not error"
fi

$(./jp .do .do .done 2>/dev/null)
if [ $? -eq 1 ];then
  pass "unterminated nested do errors"
else
  fail "unterminated nested do does not error"
fi

vals=$(./jp .do 1 2 3 .done)
if [ "$vals" = $'3\n2\n1' ];then
  pass "do block pushes two vals on the stack"
else
  printf -v valsesc "%q" "$vals"
  fail "do block pushes two vals on the stack but returns: $valsesc"
fi

seq=$(./jp .do 1 .done .do 2 .done .do 3 .done)
if [ "$seq" = $'3\n2\n1' ];then
  pass "sequential do blocks push values on stack"
else
  printf -v seqesc "%q" "$seq"
  fail "sequential do blocks return: $seqesc"
fi

nest=$(./jp .do 1 .do 2 .do 3 .done .done .done)
if [ "$nest" = $'3\n2\n1' ];then
  pass "nested do blocks push values on stack"
else
  printf -v nestesc "%q" "$nest"
  fail "nested do blocks return: $nestesc"
fi

end
