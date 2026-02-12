#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "no arguments sets all defaults" {
    parse_args
    [[ "$SHOW_ALL" == "false" ]]
    [[ "$SHOW_ALL_TIME" == "false" ]]
    [[ "$LITERAL_YESTERDAY" == "false" ]]
    [[ -z "$SCAN_DIR" ]]
    [[ ${#PASS_ARGS[@]} -eq 0 ]]
}

@test "-a sets SHOW_ALL=true" {
    parse_args -a
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "false" ]]
}

@test "-A sets SHOW_ALL=true (case insensitive)" {
    parse_args -A
    [[ "$SHOW_ALL" == "true" ]]
}

@test "--all-authors sets SHOW_ALL=true" {
    parse_args --all-authors
    [[ "$SHOW_ALL" == "true" ]]
}

@test "-t sets SHOW_ALL_TIME=true" {
    parse_args -t
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$SHOW_ALL" == "false" ]]
}

@test "-T sets SHOW_ALL_TIME=true (case insensitive)" {
    parse_args -T
    [[ "$SHOW_ALL_TIME" == "true" ]]
}

@test "--all-time sets SHOW_ALL_TIME=true" {
    parse_args --all-time
    [[ "$SHOW_ALL_TIME" == "true" ]]
}

@test "-l sets LITERAL_YESTERDAY=true" {
    parse_args -l
    [[ "$LITERAL_YESTERDAY" == "true" ]]
}

@test "-L sets LITERAL_YESTERDAY=true (case insensitive)" {
    parse_args -L
    [[ "$LITERAL_YESTERDAY" == "true" ]]
}

@test "--literal sets LITERAL_YESTERDAY=true" {
    parse_args --literal
    [[ "$LITERAL_YESTERDAY" == "true" ]]
}

@test "-d sets SCAN_DIR" {
    parse_args -d /some/path
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "-D sets SCAN_DIR (case insensitive)" {
    parse_args -D /some/path
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "--directory sets SCAN_DIR" {
    parse_args --directory /some/path
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "--directory=VALUE sets SCAN_DIR (equals syntax)" {
    parse_args --directory=/some/path
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "-d without path prints error and exits 1" {
    run parse_args -d
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"requires a directory path"* ]]
}

@test "combined flags -at set both SHOW_ALL and SHOW_ALL_TIME" {
    parse_args -at
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$LITERAL_YESTERDAY" == "false" ]]
}

@test "combined flags -AT work case-insensitively" {
    parse_args -AT
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
}

@test "combined flags -atl set all three booleans" {
    parse_args -atl
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$LITERAL_YESTERDAY" == "true" ]]
}

@test "combined flags -atd sets booleans and SCAN_DIR" {
    parse_args -atd /some/path
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "combined flags -atld sets all flags" {
    parse_args -atld /some/path
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$LITERAL_YESTERDAY" == "true" ]]
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "combined flags -atd without path prints error and exits 1" {
    run parse_args -atd
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"requires a directory path"* ]]
}

@test "unknown arguments are collected into PASS_ARGS" {
    parse_args --since="1 week ago" --author=john
    [[ ${#PASS_ARGS[@]} -eq 2 ]]
    [[ "${PASS_ARGS[0]}" == "--since=1 week ago" ]]
    [[ "${PASS_ARGS[1]}" == "--author=john" ]]
}

@test "flags and pass-through args can be mixed" {
    parse_args -a --since="1 week ago"
    [[ "$SHOW_ALL" == "true" ]]
    [[ ${#PASS_ARGS[@]} -eq 1 ]]
    [[ "${PASS_ARGS[0]}" == "--since=1 week ago" ]]
}

@test "-h calls show_help and exits 0" {
    run parse_args -h
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"yesterday - List git commits"* ]]
}

@test "--help calls show_help and exits 0" {
    run parse_args --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"yesterday - List git commits"* ]]
}

@test "parse_args resets state between calls" {
    parse_args -a
    [[ "$SHOW_ALL" == "true" ]]
    parse_args
    [[ "$SHOW_ALL" == "false" ]]
}
