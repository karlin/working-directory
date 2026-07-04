#!/usr/bin/env bats

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  load "test_helper/bats-support/load"
  load "test_helper/bats-assert/load"
  
  export WD_TESTING=1
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
  # Create scheme foo
  wdscheme foo
  # Go back to default
  wdscheme default
  # Set temporary scheme foo
  wdscheme -t foo
  
  run wdscheme
  assert_output "foo"
  assert_equal "$WDSCHEME" "foo"
  
  # The stored scheme file should still be default
  currentscheme_file="${WDHOME}/current_scheme"
  run cat "$currentscheme_file"
  assert_output "default"
}

@test "clear slots in a scheme with wdc" {
  two="${BATS_TEST_TMPDIR}/two"
  mkdir -p "$two"
  wdstore 2 "$two"
  wdc
  run wdl
  assert_line --index 2 "2"
}

@test "wdstore and wdretr defaults to slot 0" {
  zero="${BATS_TEST_TMPDIR}/zero"
  mkdir -p "$zero"
  cd "$zero"
  
  # Store current dir (which is zero) in slot 0 using no arguments
  wdstore
  
  cd ..
  # Retrieve slot 0 using no arguments
  wdretr
  
  run pwd
  assert_output "$zero"
}

@test "clear slot by setting to period" {
  three="${BATS_TEST_TMPDIR}/three"
  mkdir -p "$three"
  wdstore 3 "$three"
  
  # Verify it is set
  run wdl
  assert_line --index 3 "3 ${three}"
  
  # Clear it by setting to period
  wdstore 3 "."
  
  # Verify it is cleared in wdl
  run wdl
  assert_line --index 3 "3"
  
  # Verify wdretr 3 does not change the directory
  start_dir="$(pwd)"
  wdretr 3
  current_dir="$(pwd)"
  assert_equal "$start_dir" "$current_dir"
}

@test "scheme name containing spaces" {
  wdscheme "my space scheme"
  run wdscheme
  assert_output "my space scheme"
  
  # Verify the file is created with spaces in the name
  [ -f "${WDHOME}/my space scheme.scheme" ]
}

@test "wdscheme completion" {
  wdscheme foo
  wdscheme bar
  
  # Simulate typing "wdscheme f"
  COMP_WORDS=(wdscheme f)
  COMP_CWORD=1
  _wd_scheme_completion
  
  assert_equal "${COMPREPLY[0]}" "foo"
  assert_equal "${#COMPREPLY[@]}" 1
}

@test "wdscheme completion with spaces" {
  wdscheme "foo bar"
  
  # Simulate typing "wdscheme f"
  COMP_WORDS=(wdscheme f)
  COMP_CWORD=1
  _wd_scheme_completion
  
  assert_equal "${COMPREPLY[0]}" "foo\ bar"
}

@test "aliases are created" {
  shopt -s expand_aliases
  # Re-source wd.sh with aliases expansion enabled
  load "${DIR}/../wd/wd.sh"
  
  # Check if aliases exist
  run alias wd
  assert_output "alias wd='wdretr 0'"
  run alias wds
  assert_output "alias wds='wdstore 0'"
  run alias wd3
  assert_output "alias wd3='wdretr 3'"
  run alias wds3
  assert_output "alias wds3='wdstore 3'"
}