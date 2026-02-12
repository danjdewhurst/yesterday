#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "help output documents --ai flag" {
    run show_help
    assert_output --partial "--ai"
}

@test "help output documents --setup flag" {
    run show_help
    assert_output --partial "--setup"
}

@test "help output shows AI example" {
    run show_help
    assert_output --partial "yesterday --ai"
}

@test "help output shows combined AI example" {
    run show_help
    assert_output --partial "yesterday -ai"
}

@test "help output shows setup example" {
    run show_help
    assert_output --partial "yesterday --setup"
}
