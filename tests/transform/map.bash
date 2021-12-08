#!/bin/bash
source "test-bootstrap.bash"
IFS=

$(./jp [1,2,3] .map 2>/dev/null)
if [ $? -eq 1 ];then
  pass "map without expression errors"
else
  fail "map without expression does not error"
fi

$(./jp [1,2,3] .map [1] .map 2>/dev/null)
if [ $? -eq 1 ];then
  pass "seq maps without expression errors"
else
  fail "seq maps without expression do not error"
fi

arrvals=$(./jp [1,2,3] .map .do .done)
if [ "$arrvals" = $'3\n2\n1' ];then
  pass "empty map pushes array elements on to stack"
else
  printf -v arrvalsesc "%q" "$arrvals"
  fail "empty map returns: $arrvalsesc"
fi

objvals=$(./jp '{"a":1,"b":2}' .map .do .done)
if [ "$objvals" = $'{"b":2}\n{"a":1}' ];then
  pass "empty map pushes object pairs on to stack"
else
  printf -v objvalsesc "%q" "$objvals"
  fail "empty map returns: $objvalsesc"
fi

seq=$(./jp '{"a":1,"b":2}' .map .do .done .concat .map .v)
if [ "$seq" = $'1\n2' ];then
  pass "sequential maps chain stack operations"
else
  printf -v seqesc "%q" "$seq"
  fail "sequential maps return: $seqesc"
fi

nest=$(./jp '{"a":1,"b":2}' .map .map .v)
if [ "$nest" = $'2\n1' ];then
  pass "nested maps chain stack operations"
else
  printf -v nestesc "%q" "$nest"
  fail "nested maps return: $nestesc"
fi

end
