#!/bin/bash
source "test-bootstrap.bash"
IFS=

expect=$'[\n\t1,\n\t2,\n\t3\n]'
output=$(jp -pni '	' $expect)
if [ "$output" = $expect ];then
  pass "-i forces indent to tab"
else
  printf -v outputesc "%q" "$output"
  fail "-i doesn't force indent to tab: $outputesc"
fi

end
