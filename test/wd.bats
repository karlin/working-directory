#!/usr/bin/env bats

setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    load "test_helper/bats-support/load"
    load "test_helper/bats-assert/load"
    
    export WDHOME="${BATS_TEST_TMPDIR}/.wd"
    assert_not_equal "$WDHOME" "${HOME}/.wd"

    load "${DIR}/../wd/wd.sh"
}

@test "store current directory" {
  zero="${BATS_TEST_TMPDIR}/zero"
  mkdir -p "$zero"
  cd "$zero"
  wdstore 0
  cd ..
  wdretr 0
  run pwd
  assert_output "$zero"
  assert_equal "$WD0" "$zero"
}

@test "list wd slots" {
  one="${BATS_TEST_TMPDIR}/one"
  mkdir -p "$one"
  wdstore 1 "$one"
  run wdl
  assert_line --index 0 '0'
  assert_line --index 1 "1 ${one}"
  assert_line --index 2 '2'
  assert_line --index 3 '3'
  assert_line --index 4 '4'
  assert_line --index 5 '5'
  assert_line --index 6 '6'
  assert_line --index 7 '7'
  assert_line --index 8 '8'
  assert_line --index 9 '9'
}

@test "create new scheme that doesn't exist" {
  run wdscheme
  assert_output "default"
  wdscheme foo
  run wdscheme
  assert_output "foo"
}

@test "change to an existing scheme" {
  run wdscheme
  assert_output "default"
  wdscheme foo
  wdscheme default
  run wdscheme
  assert_output "default"
}

@test "wdl without setting a scheme" {
  rm "${BATS_TEST_TMPDIR}/.wd/default.scheme"
  run wdl
  assert_line --index 0 "wd: Creating new scheme default"
  assert_line --index 1 "wd: new scheme already exists, not overwriting!"
  run wdscheme
  assert_output "default"
}

@test "create a new scheme when the current one is removed" {
  rm "${BATS_TEST_TMPDIR}/.wd/default.scheme"
  run wdscheme
  assert_output "wd: Creating new scheme default
wd: new scheme already exists, not overwriting!
wd: stored scheme is missing, falling back to: default
default"
}

@test "set a new, temporary scheme" {
  wdscheme foo
  export WDSCHEME=default
  run wdscheme
  assert_output "default"
}

@test "wdscheme -t to set shell-local scheme override" {
  skip
}

@test "clear slots in a scheme with wdc" {
  two="${BATS_TEST_TMPDIR}/two"
  mkdir -p "$two"
  wdstore 2 "$two"
  wdc
  run wdl
  assert_line --index 2 "2"
}