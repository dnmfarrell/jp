#!/bin/bash
source test-bootstrap.bash

function test_should_halt {
  cat tests/share/ec2-describe-instances.json | ./jp -s
  ok $(( $? == 0 )) "jp didn't halt on large input"
}

test_should_halt
end
