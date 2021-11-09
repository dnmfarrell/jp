#!/bin/bash
source "test-bootstrap.bash"

function test_transform {
  local filepath="$1"
  local expect=$(cat "$filepath")
  local result=$(./jp "$expect")
  if [ "$result" = "$expect" ];then
    pass "$filepath returns expected"
  else
    printf -v returnesc "%q" "$return"
    fail "$filepath returns unexpected result: $returnesc"
  fi
}

for file in tests/share/JSONTestSuite/test_transform/*;do
  test_transform "$file"
done

end
