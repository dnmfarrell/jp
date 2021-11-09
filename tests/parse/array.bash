#!/bin/bash
source "test-bootstrap.bash"

function test_good_token {
  jp.trace "test_good_token"
  JP_BUF=('["octocat","atom","electron","api"]')
  jp.chomp
  jp.array
  if [ "${JP_TOKENS:0:1}" = '[' ];then
    pass "parse opening bracket token"
  else
    fail "parse opening bracket token"
  fi
  if [ ${JP_TOKENS:2:9} = '"octocat"' ];then
    pass "parse first member token"
  else
    fail "parse first member token failed: '${JP_TOKENS:2:8}'"
  fi
  if [ ${JP_TOKENS:36:5} = '"api"' ];then
    pass "parse last member token"
  else
    fail "parse last member token failed: '${JP_TOKENS:37:5}'"
  fi
  if [ ${JP_TOKENS:42:1} = ']' ];then
    pass "parse closing bracket token"
  else
    fail "parse closing bracket token"
  fi
}

function test_unclosed {
  jp.trace "test_unclosed"
  JP_BUF=('[')
  jp.chomp
  jp.array 2> /dev/null # silence the error msg
  ok $(( $? == 1 )) "parse '[' is an error"
}

function test_trailing_comma {
  jp.trace "test_trailing_comma"
  JP_BUF=('[1,')
  jp.chomp
  jp.array 2> /dev/null # silence the error msg
  ok $(( $? == 1 )) "parse '[,' is an error"
}

function test_leading_comma {
  jp.trace "test_leading_comma"
  JP_BUF=('[,')
  jp.chomp
  jp.array 2> /dev/null # silence the error msg
  ok $(( $? == 1 )) "parse '[1,' is an error"
}

test_good_token
test_unclosed
test_leading_comma
test_trailing_comma
end
