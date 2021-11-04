#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/../../test-bootstrap.bash"

function test_should_halt {
  cat "$DIR/../share/ec2-describe-instances.json" | "$DIR/../../jp" -p
  ok $(( $? == 0 )) "jp didn't halt on large input"
}

test_should_halt
end
