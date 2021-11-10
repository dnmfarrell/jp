#!/bin/bash
source "test-bootstrap.bash"

function test_good_token {
  JP_IDX=0
  JP_LINE=1
  JP_BUF='null'
  JP_BUF_MAXLEN="${#JP_BUF}"
  jp_chomp
  jp_null
  ok $(( "${JP_TOKENS[0]}" == "null" )) "parse 'null' token"
}

function test_bad_token {
  JP_IDX=0
  JP_LINE=1
  JP_BUF='nul'
  JP_BUF_MAXLEN="${#JP_BUF}"
  jp_chomp
  jp_null 2> /dev/null # silence the error msg
  ok $(( $? == 1 )) "parse 'nul' is an error"
}

test_good_token
test_bad_token
end
