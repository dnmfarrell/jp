#!/bin/bash
source "test-bootstrap.bash"

function test_♥_token {
  jp.trace "test_good_token"
  JP_BUF=('"\u2665"')
  jp.chomp
  jp.string
  if [ "${JP_TOKENS:0:-1}" == '"\u2665"' ];then
    pass "parse unicode '♥' token"
  else
    fail "parse unicode '♥' token failed: '${JP_TOKENS:0:-1}'"
  fi
}

function test_too_short {
  jp.trace "test_bad_token"
  JP_BUF=('"\u265"')
  jp.chomp
  jp.string 2> /dev/null
  ok $(( $? == 1 )) "parse '\u266' is an error (escape too short)"
}

function test_too_long {
  jp.trace "test_bad_token"
  JP_BUF=('"\u26657"')
  jp.chomp
  jp.string 2> /dev/null
  ok $(( $? == 1 )) "parse '\u26657' is an error (escape too long)"
}

test_♥_token
test_too_short
test_too_long
end
