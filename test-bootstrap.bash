#!/bin/bash
source jp
JP_TEST_COUNT=0
JP_TEST_FAIL_COUNT=0

function ok {
  (( JP_TEST_COUNT++ ))
  if [[ "$1" != 1 ]];then
    (( JP_TEST_FAIL_COUNT++ ))
    echo -n "not "
  fi
  echo "ok $JP_TEST_COUNT $2"
}

function pass {
  (( JP_TEST_COUNT++ ))
  echo "ok $JP_TEST_COUNT $1"
}

function fail {
  (( JP_TEST_COUNT++ ))
  (( JP_TEST_FAIL_COUNT++ ))
  echo "not ok $JP_TEST_COUNT $1"
}

function skip {
  pass "# SKIP $1"
}

function todo {
  pass "# TODO $1"
}

function end {
  echo "1..$JP_TEST_COUNT"
  exit "$JP_TEST_FAIL_COUNT"
}
