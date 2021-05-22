#!/bin/bash
source "test-bootstrap.bash"

function test_good_token {
  jp.trace "test_good_token"
  JP_BUF="null"
  jp.chomp
  jp.null
  ok $(( $JP_R == "null" )) "parse 'null' token"
}

function test_bad_token {
  jp.trace "test_bad_token"
  JP_BUF="nul"
  jp.chomp
  jp.null
  ok $(( $? == 1 )) "parse 'nul' is an error"
}

test_good_token
test_bad_token
end
