#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "-d without argument exits 1 with error" {
    run parse_args -d
    assert_failure
    assert_output --partial "requires a directory path"
}

@test "--directory without argument exits 1 with error" {
    run parse_args --directory
    assert_failure
    assert_output --partial "requires a directory path"
}

@test "combined -atd without path exits 1 with error" {
    run parse_args -atd
    assert_failure
    assert_output --partial "requires a directory path"
}

@test "not in git repo without -d exits 1" {
    cd "$BATS_TEST_TMPDIR"
    run main
    assert_failure
    assert_output --partial "Not a git repository"
}

@test "-d with nonexistent path exits 1" {
    run main -d /nonexistent/path/that/does/not/exist
    assert_failure
    assert_output --partial "Directory not found"
}

@test "-d with directory containing no git repos exits 1" {
    mkdir -p "$BATS_TEST_TMPDIR/empty-dir"
    run main -d "$BATS_TEST_TMPDIR/empty-dir"
    assert_failure
    assert_output --partial "No git repositories found"
}
