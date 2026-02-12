#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "no arguments keeps USE_AI=false" {
    parse_args
    [[ "$USE_AI" == "false" ]]
}

@test "--ai sets USE_AI=true" {
    parse_args --ai
    [[ "$USE_AI" == "true" ]]
}

@test "-i sets USE_AI=true" {
    parse_args -i
    [[ "$USE_AI" == "true" ]]
}

@test "-I sets USE_AI=true (case insensitive)" {
    parse_args -I
    [[ "$USE_AI" == "true" ]]
}

@test "--ai does not affect other flags" {
    parse_args --ai
    [[ "$SHOW_ALL" == "false" ]]
    [[ "$SHOW_ALL_TIME" == "false" ]]
    [[ "$LITERAL_YESTERDAY" == "false" ]]
    [[ -z "$SCAN_DIR" ]]
}

@test "-ai sets both SHOW_ALL and USE_AI" {
    parse_args -ai
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$USE_AI" == "true" ]]
}

@test "-ia sets both SHOW_ALL and USE_AI (order independent)" {
    parse_args -ia
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$USE_AI" == "true" ]]
}

@test "-ait sets SHOW_ALL, SHOW_ALL_TIME, and USE_AI" {
    parse_args -ait
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$USE_AI" == "true" ]]
}

@test "-aild sets four flags plus SCAN_DIR" {
    parse_args -aild /some/path
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$USE_AI" == "true" ]]
    [[ "$LITERAL_YESTERDAY" == "true" ]]
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "-aitld sets all five flags" {
    parse_args -aitld /some/path
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$USE_AI" == "true" ]]
    [[ "$LITERAL_YESTERDAY" == "true" ]]
    [[ "$SCAN_DIR" == "/some/path" ]]
}

@test "--ai can be combined with long flags" {
    parse_args --all-authors --ai --all-time
    [[ "$SHOW_ALL" == "true" ]]
    [[ "$SHOW_ALL_TIME" == "true" ]]
    [[ "$USE_AI" == "true" ]]
}

@test "parse_args resets USE_AI between calls" {
    parse_args --ai
    [[ "$USE_AI" == "true" ]]
    parse_args
    [[ "$USE_AI" == "false" ]]
}
