#!/bin/bash
source "test-bootstrap.bash"

function test_good_token {
  jp.trace "test_good_token"
  JP_BUF=("null")
  jp.chomp
  jp.null
  ok $(( "${JP_TOKENS[0]}" == "null" )) "parse 'null' token"
}

function test_bad_token {
  jp.trace "test_bad_token"
  JP_BUF=("null")
  jp.chomp
  jp.null 2> /dev/null # silence the error msg
  ok $(( $? == 1 )) "parse 'nul' is an error"
}

test_good_token
test_bad_token
end
