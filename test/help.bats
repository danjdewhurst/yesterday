#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "--help prints usage and exits 0" {
    run show_help
    assert_success
    assert_output --partial "Usage: yesterday"
}

@test "-h prints usage and exits 0" {
    run parse_args -h
    assert_success
    assert_output --partial "Usage: yesterday"
}

@test "-H prints usage and exits 0 (case insensitive)" {
    run parse_args -H
    assert_success
    assert_output --partial "Usage: yesterday"
}

@test "help output includes Options section" {
    run show_help
    assert_output --partial "Options:"
}

@test "help output includes Examples section" {
    run show_help
    assert_output --partial "Examples:"
}

@test "help output documents all flags" {
    run show_help
    assert_output --partial "--all-authors"
    assert_output --partial "--all-time"
    assert_output --partial "--literal"
    assert_output --partial "--directory"
    assert_output --partial "--help"
}
