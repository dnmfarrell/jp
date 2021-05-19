#!/bin/bash
source jp
JP_ERROR_COUNT=0
JP_TEST_COUNT=0
JP_TEST_FAIL_COUNT=0

function jp.error {
  jp.trace "error"
  (( JP_ERROR_COUNT++ ))
}

function ok {
  jp.trace "ok $*"
  (( JP_TEST_COUNT++ ))
  if [[ "$1" != 1 ]];then
    (( JP_TEST_FAIL_COUNT++ ))
    echo -n "not "
  fi
  echo "ok $JP_TEST_COUNT $2"
}

function end {
  echo "1..$JP_TEST_COUNT"
  exit "$JP_TEST_FAIL_COUNT"
}
