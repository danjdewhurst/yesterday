#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
    load 'test_helper/git-helpers'

    # Mock date to a non-Monday (Wednesday = 3) by default
    create_date_mock "$BATS_TEST_TMPDIR" "3"
    PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

# Helper to check if LOG_ARGS contains a value
log_args_contain() {
    local target="$1"
    for arg in "${LOG_ARGS[@]}"; do
        [[ "$arg" == "$target" ]] && return 0
    done
    return 1
}

# Helper to check if LOG_ARGS contains a value matching a prefix
log_args_match_prefix() {
    local prefix="$1"
    for arg in "${LOG_ARGS[@]}"; do
        [[ "$arg" == ${prefix}* ]] && return 0
    done
    return 1
}

@test "always includes --all flag" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    log_args_contain "--all"
}

@test "always includes format and date format" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    log_args_contain "--format=%h|%cd|%an|%s"
    log_args_match_prefix "--date=format:"
}

@test "default: includes --author and --since=yesterday" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    log_args_contain "--author=Test User"
    log_args_contain "--since=yesterday"
}

@test "SHOW_ALL=true omits --author" {
    SHOW_ALL=true; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    ! log_args_match_prefix "--author"
}

@test "SHOW_ALL_TIME=true omits --since" {
    SHOW_ALL=false; SHOW_ALL_TIME=true; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    ! log_args_match_prefix "--since"
}

@test "both SHOW_ALL and SHOW_ALL_TIME omit author and since" {
    SHOW_ALL=true; SHOW_ALL_TIME=true; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    ! log_args_match_prefix "--author"
    ! log_args_match_prefix "--since"
}

@test "custom --author in PASS_ARGS suppresses default author" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=("--author=someone")
    build_log_args "Test User"
    ! log_args_contain "--author=Test User"
    log_args_contain "--author=someone"
}

@test "custom --since in PASS_ARGS suppresses default since" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=("--since=1 week ago")
    build_log_args "Test User"
    ! log_args_contain "--since=yesterday"
    log_args_contain "--since=1 week ago"
}

@test "custom --after in PASS_ARGS suppresses default since" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=("--after=2025-01-01")
    build_log_args "Test User"
    ! log_args_match_prefix "--since"
    log_args_contain "--after=2025-01-01"
}

@test "Monday detection: uses --since=last friday on Mondays" {
    create_date_mock "$BATS_TEST_TMPDIR" "1"
    PATH="$BATS_TEST_TMPDIR/bin:$PATH"

    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    log_args_contain "--since=last friday"
}

@test "Monday with LITERAL_YESTERDAY=true uses --since=yesterday" {
    create_date_mock "$BATS_TEST_TMPDIR" "1"
    PATH="$BATS_TEST_TMPDIR/bin:$PATH"

    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=true; PASS_ARGS=()
    build_log_args "Test User"
    log_args_contain "--since=yesterday"
    ! log_args_contain "--since=last friday"
}

@test "non-Monday uses --since=yesterday regardless of LITERAL_YESTERDAY" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args "Test User"
    log_args_contain "--since=yesterday"
}

@test "empty git_user with SHOW_ALL=false does not add --author=" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=()
    build_log_args ""
    ! log_args_match_prefix "--author"
}

@test "PASS_ARGS are appended to LOG_ARGS" {
    SHOW_ALL=false; SHOW_ALL_TIME=false; LITERAL_YESTERDAY=false; PASS_ARGS=("--graph" "--oneline")
    build_log_args "Test User"
    log_args_contain "--graph"
    log_args_contain "--oneline"
}
