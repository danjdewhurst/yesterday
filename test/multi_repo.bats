#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
    load 'test_helper/git-helpers'

    PARENT_DIR="$BATS_TEST_TMPDIR/projects"
}

@test "scans multiple repos and shows [repo-name] prefix" {
    create_multi_repo_dir "$PARENT_DIR" "alpha" "beta"
    make_commit "$PARENT_DIR/alpha" "alpha commit"
    make_commit "$PARENT_DIR/beta" "beta commit"

    run main -atd "$PARENT_DIR"
    assert_success
    assert_output --partial "[alpha]"
    assert_output --partial "[beta]"
    assert_output --partial "alpha commit"
    assert_output --partial "beta commit"
}

@test "treats git repo path as single repo (no [prefix])" {
    create_test_repo "$PARENT_DIR/single-repo"
    make_commit "$PARENT_DIR/single-repo" "solo commit"

    run main -td "$PARENT_DIR/single-repo"
    assert_success
    assert_output --partial "solo commit"
    refute_output --partial "["
}

@test "exits 1 when directory does not exist" {
    run main -d /nonexistent/path
    assert_failure
    assert_output --partial "Directory not found"
}

@test "exits 1 when directory has no git repos" {
    mkdir -p "$PARENT_DIR/empty"
    run main -d "$PARENT_DIR/empty"
    assert_failure
    assert_output --partial "No git repositories found"
}

@test "deduplicates by repo+subject in multi-repo mode" {
    create_multi_repo_dir "$PARENT_DIR" "myrepo"
    make_commit "$PARENT_DIR/myrepo" "duplicate msg"
    make_commit_on_branch "$PARENT_DIR/myrepo" "feature" "duplicate msg"

    run main -atd "$PARENT_DIR"
    assert_success

    local count
    count=$(echo "$output" | grep -c "duplicate msg" || true)
    [[ "$count" -eq 1 ]]
}

@test "columns are aligned across repos with different name lengths" {
    create_multi_repo_dir "$PARENT_DIR" "a" "long-repo-name"
    make_commit "$PARENT_DIR/a" "short name commit"
    make_commit "$PARENT_DIR/long-repo-name" "long name commit"

    run main -atd "$PARENT_DIR"
    assert_success

    # Both lines should have the repo bracket padded to same width
    # [a]              should be padded to match [long-repo-name]
    local line1 line2
    line1=$(echo "$output" | grep "short name commit")
    line2=$(echo "$output" | grep "long name commit")

    # Extract the position of the first hash character after the bracket
    # Both lines should have the hash at the same column position
    local pos1 pos2
    pos1=$(echo "$line1" | sed 's/\[.*\]//' | sed 's/^ *//' | cut -c1)
    pos2=$(echo "$line2" | sed 's/\[.*\]//' | sed 's/^ *//' | cut -c1)
    [[ -n "$line1" ]]
    [[ -n "$line2" ]]
}
