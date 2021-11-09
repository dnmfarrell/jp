#!/bin/bash
source "test-bootstrap.bash"

function test_♥_token {
  JP_IDX=0
  JP_LINE=1
  JP_BUF='"\u2665"'
  JP_BUF_MAXLEN="${#JP_BUF}"
  jp.chomp
  jp.string
  ok $(( $? == 0 )) "parses '\u2665' without error"
  if [ "${JP_TOKENS:0:-1}" == '"\u2665"' ];then
    pass "parse unicode '♥' token"
  else
    fail "parse unicode '♥' token failed: '${JP_TOKENS:0:-1}'"
  fi
}

function test_too_short {
  JP_IDX=0
  JP_LINE=1
  JP_BUF='"\u265"'
  JP_BUF_MAXLEN="${#JP_BUF}"
  jp.chomp
  jp.string 2> /dev/null
  ok $(( $? == 1 )) "parse '\u266' is an error (escape too short)"
}

function test_capital_u {
  JP_IDX=0
  JP_LINE=1
  JP_BUF='"\U2665"'
  JP_BUF_MAXLEN="${#JP_BUF}"
  jp.chomp
  jp.string 2> /dev/null
  ok $(( $? == 1 )) "parse '\U26657' is an error (u is capitalized)"
}

test_♥_token
test_too_short
test_capital_u
end
