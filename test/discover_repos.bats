#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "finds child directories with .git" {
    mkdir -p "$BATS_TEST_TMPDIR/parent/repo-a/.git"
    mkdir -p "$BATS_TEST_TMPDIR/parent/repo-b/.git"

    discover_repos "$BATS_TEST_TMPDIR/parent"
    [[ ${#REPOS[@]} -eq 2 ]]
}

@test "ignores child directories without .git" {
    mkdir -p "$BATS_TEST_TMPDIR/parent/not-a-repo"

    discover_repos "$BATS_TEST_TMPDIR/parent"
    [[ ${#REPOS[@]} -eq 0 ]]
}

@test "mixed: returns only directories with .git" {
    mkdir -p "$BATS_TEST_TMPDIR/parent/repo-a/.git"
    mkdir -p "$BATS_TEST_TMPDIR/parent/not-a-repo"
    mkdir -p "$BATS_TEST_TMPDIR/parent/repo-b/.git"

    discover_repos "$BATS_TEST_TMPDIR/parent"
    [[ ${#REPOS[@]} -eq 2 ]]
}

@test "returns empty array for empty directory" {
    mkdir -p "$BATS_TEST_TMPDIR/parent"

    discover_repos "$BATS_TEST_TMPDIR/parent"
    [[ ${#REPOS[@]} -eq 0 ]]
}

@test "ignores nested repos (only immediate children)" {
    mkdir -p "$BATS_TEST_TMPDIR/parent/outer/inner/.git"
    # outer itself has no .git

    discover_repos "$BATS_TEST_TMPDIR/parent"
    [[ ${#REPOS[@]} -eq 0 ]]
}
