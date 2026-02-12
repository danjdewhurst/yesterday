#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
    load 'test_helper/git-helpers'

    REPO_DIR="$BATS_TEST_TMPDIR/test-repo"
    create_test_repo "$REPO_DIR" "Test User" "test@example.com"
}

@test "shows commits from current user" {
    make_commit "$REPO_DIR" "add feature"
    make_commit "$REPO_DIR" "fix bug"

    cd "$REPO_DIR"
    run main -t
    assert_success
    assert_output --partial "add feature"
    assert_output --partial "fix bug"
}

@test "filters to current user by default" {
    make_commit "$REPO_DIR" "my commit"
    make_commit_as "$REPO_DIR" "Other Person" "other@example.com" "their commit"

    cd "$REPO_DIR"
    run main -t
    assert_success
    assert_output --partial "my commit"
    refute_output --partial "their commit"
}

@test "-a shows commits from all authors" {
    make_commit "$REPO_DIR" "my commit"
    make_commit_as "$REPO_DIR" "Other Person" "other@example.com" "their commit"

    cd "$REPO_DIR"
    run main -at
    assert_success
    assert_output --partial "my commit"
    assert_output --partial "their commit"
}

@test "deduplicates by commit subject" {
    make_commit "$REPO_DIR" "shared work"
    make_commit_on_branch "$REPO_DIR" "feature-branch" "shared work"

    cd "$REPO_DIR"
    run main -at
    assert_success

    # Count occurrences of "shared work" in output
    local count
    count=$(echo "$output" | grep -c "shared work" || true)
    [[ "$count" -eq 1 ]]
}

@test "output contains hash, date, author, and message" {
    make_commit "$REPO_DIR" "test commit"

    cd "$REPO_DIR"
    run main -t
    assert_success

    # Output should have columns: hash  date  author  message
    # Hash is 7+ chars, date is YYYY-MM-DD HH:MM format
    [[ "$output" =~ [a-f0-9]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]+[0-9]{2}:[0-9]{2}[[:space:]]+Test\ User[[:space:]]+test\ commit ]]
}

@test "pass-through arguments work" {
    make_commit "$REPO_DIR" "old commit" "2020-01-01 12:00:00"
    make_commit "$REPO_DIR" "new commit"

    cd "$REPO_DIR"
    run main -a --since="1 hour ago"
    assert_success
    assert_output --partial "new commit"
    refute_output --partial "old commit"
}
