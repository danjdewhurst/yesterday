#!/usr/bin/env bash

# Create a minimal git repo with a configured user
# Usage: create_test_repo "/path/to/repo" ["User Name"] ["user@email.com"]
create_test_repo() {
    local repo_dir="$1"
    local user_name="${2:-Test User}"
    local user_email="${3:-test@example.com}"

    mkdir -p "$repo_dir"
    git -C "$repo_dir" init --quiet
    git -C "$repo_dir" config user.name "$user_name"
    git -C "$repo_dir" config user.email "$user_email"
    # Create initial commit so HEAD exists
    touch "$repo_dir/.gitkeep"
    git -C "$repo_dir" add -A
    git -C "$repo_dir" commit --quiet -m "initial commit"
}

# Make a commit in repo with optional controlled date
# Usage: make_commit "/path/to/repo" "commit message" ["2025-01-14 15:00:00"]
make_commit() {
    local repo_dir="$1"
    local message="$2"
    local date="${3:-}"

    # Create unique content to avoid "nothing to commit"
    echo "$message - $(date +%s%N)" >> "$repo_dir/changes.txt"
    git -C "$repo_dir" add -A

    if [[ -n "$date" ]]; then
        GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
            git -C "$repo_dir" commit --quiet -m "$message"
    else
        git -C "$repo_dir" commit --quiet -m "$message"
    fi
}

# Make a commit as a specific author
# Usage: make_commit_as "/path/to/repo" "Author Name" "author@email.com" "commit message" ["date"]
make_commit_as() {
    local repo_dir="$1"
    local author_name="$2"
    local author_email="$3"
    local message="$4"
    local date="${5:-}"

    echo "$message - $(date +%s%N)" >> "$repo_dir/changes.txt"
    git -C "$repo_dir" add -A

    if [[ -n "$date" ]]; then
        GIT_AUTHOR_NAME="$author_name" GIT_AUTHOR_EMAIL="$author_email" \
        GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
            git -C "$repo_dir" commit --quiet -m "$message"
    else
        GIT_AUTHOR_NAME="$author_name" GIT_AUTHOR_EMAIL="$author_email" \
            git -C "$repo_dir" commit --quiet -m "$message"
    fi
}

# Make a commit on a named branch, then return to previous branch
# Usage: make_commit_on_branch "/path/to/repo" "branch-name" "commit message" ["date"]
make_commit_on_branch() {
    local repo_dir="$1"
    local branch="$2"
    local message="$3"
    local date="${4:-}"

    local original_branch
    original_branch=$(git -C "$repo_dir" branch --show-current)
    git -C "$repo_dir" checkout --quiet -B "$branch"
    make_commit "$repo_dir" "$message" "$date"
    git -C "$repo_dir" checkout --quiet "$original_branch"
}

# Create a parent directory with multiple child git repos
# Usage: create_multi_repo_dir "/path/to/parent" "repo1" "repo2" "repo3"
create_multi_repo_dir() {
    local parent_dir="$1"
    shift
    mkdir -p "$parent_dir"
    for repo_name in "$@"; do
        create_test_repo "$parent_dir/$repo_name"
    done
}

# Create a PATH-shimmed date mock that returns a controlled day-of-week
# Only intercepts `date +%u`; all other invocations pass through to real date
# Usage: create_date_mock "$BATS_TEST_TMPDIR" "1"  # 1=Monday
create_date_mock() {
    local mock_dir="$1"
    local day_of_week="$2"
    local real_date
    real_date="$(which date)"

    mkdir -p "$mock_dir/bin"
    cat > "$mock_dir/bin/date" << MOCKEOF
#!/usr/bin/env bash
for arg in "\$@"; do
    if [[ "\$arg" == "+%u" ]]; then
        echo "$day_of_week"
        exit 0
    fi
done
"$real_date" "\$@"
MOCKEOF
    chmod +x "$mock_dir/bin/date"
}
