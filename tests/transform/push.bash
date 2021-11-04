#!/bin/bash
source "test-bootstrap.bash"
IFS=

string=$(echo '"Hello"' | jp '"World!"' '""')
if [ $string = $'""\n"World!"\n"Hello"' ];then
  pass "push string"
else
  printf -v stringesc "%q" "$string"
  fail "push string: got $stringesc"
fi

num=$(echo '1' | jp 2.0 -50)
if [ "$num" = $'-50\n2.0\n1' ];then
  pass "push num"
else
  printf -v numesc "%q" "$num"
  fail "push num: got $numesc"
fi

bool=$(echo 'false' | jp 'true')
if [ "$bool" = $'true\nfalse' ];then
  pass "push bool"
else
  printf -v boolesc "%q" "$bool"
  fail "push bool: got $boolesc"
fi

null=$(echo 'null' | jp 'null')
if [ "$null" = $'null\nnull' ];then
  pass "push null"
else
  printf -v nullesc "%q" "$null"
  fail "push null: got $nullesc"
fi

array=$(echo '[1]' | jp '[1,2,[3]]' '[]')
if [ "$array" = $'[]\n[1,2,[3]]\n[1]' ];then
  pass "push array"
else
  printf -v arrayesc "%q" "$array"
  fail "push array: got $arrayesc"
fi

object=$(echo '{"a":1}' | jp '{"b":{"c":3}}' '{}')
if [ "$object" = $'{}\n{"b":{"c":3}}\n{"a":1}' ];then
  pass "push object"
else
  printf -v objectesc "%q" "$object"
  fail "push object: got $objectesc"
fi

end
