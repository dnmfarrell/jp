#!/bin/bash
source "test-bootstrap.bash"

function test_good_token {
  jp.trace "test_good_token"
  JP_BUF=(n u l l)
  JP_IDX=0
  jp.chomp
  jp.null
  ok $(( $JP_R == "null" )) "parse 'null' token"
}

function test_bad_token {
  jp.trace "test_bad_token"
  JP_BUF=(n u l)
  JP_IDX=0
  jp.chomp
  jp.null
  ok $(( $? == 1 )) "parse 'nul' is an error"
}

test_good_token
test_bad_token
end
