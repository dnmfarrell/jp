#!/bin/bash
source test-bootstrap.bash

if [ -z "$JP_TEST_SLOW" ];then
  skip "slow tests disabled"
else
  cat tests/share/ec2-describe-instances.json | ./jp -s
  ok $(( $? == 0 )) "jp didn't halt on large input"
fi

end
