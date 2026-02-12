#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
    load 'test_helper/git-helpers'

    REPO_DIR="$BATS_TEST_TMPDIR/test-repo"
    create_test_repo "$REPO_DIR" "Test User" "test@example.com"

    # Ensure no real config interferes
    export HOME="$BATS_TEST_TMPDIR/fakehome"
    mkdir -p "$HOME"
}

# --- load_config ---

@test "load_config fails when no config file exists" {
    run load_config
    assert_failure
    assert_output --partial "No AI config found"
    assert_output --partial "--setup"
}

@test "load_config sources config file" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=openai
OPENAI_API_KEY=sk-test123
OPENAI_MODEL=gpt-4o-mini
EOF
    load_config
    [[ "$AI_PROVIDER" == "openai" ]]
    [[ "$OPENAI_API_KEY" == "sk-test123" ]]
    [[ "$OPENAI_MODEL" == "gpt-4o-mini" ]]
}

@test "load_config works with all providers" {
    for provider in openai claude gemini ollama; do
        mkdir -p "$HOME/.config/yesterday"
        echo "AI_PROVIDER=$provider" > "$HOME/.config/yesterday/config"
        load_config
        [[ "$AI_PROVIDER" == "$provider" ]]
    done
}

# --- detect_json_tool ---

@test "detect_json_tool finds jq when available" {
    if ! command -v jq &>/dev/null; then
        skip "jq not installed"
    fi
    detect_json_tool
    [[ "$JSON_TOOL" == "jq" ]]
}

@test "detect_json_tool finds python3 as fallback" {
    if ! command -v python3 &>/dev/null; then
        skip "python3 not installed"
    fi
    # Hide jq by overriding PATH to exclude it
    local temp_bin="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$temp_bin"
    # Symlink everything except jq
    for cmd in /usr/bin/*; do
        local name
        name=$(basename "$cmd")
        [[ "$name" == "jq" ]] && continue
        ln -sf "$cmd" "$temp_bin/$name" 2>/dev/null || true
    done
    # Add python3 explicitly
    ln -sf "$(which python3)" "$temp_bin/python3"

    PATH="$temp_bin" detect_json_tool
    [[ "$JSON_TOOL" == "python3" ]]
}

@test "detect_json_tool fails when neither jq nor python3 available" {
    PATH="/nonexistent" run detect_json_tool
    assert_failure
    assert_output --partial "jq or python3 is required"
}

# --- parse_ai_response ---

@test "parse_ai_response extracts OpenAI response" {
    detect_json_tool
    local body='{"choices":[{"message":{"content":"Test summary"}}]}'
    run parse_ai_response "$body" "openai"
    assert_success
    assert_output "Test summary"
}

@test "parse_ai_response extracts Claude response" {
    detect_json_tool
    local body='{"content":[{"text":"Test summary"}]}'
    run parse_ai_response "$body" "claude"
    assert_success
    assert_output "Test summary"
}

@test "parse_ai_response extracts Gemini response" {
    detect_json_tool
    local body='{"candidates":[{"content":{"parts":[{"text":"Test summary"}]}}]}'
    run parse_ai_response "$body" "gemini"
    assert_success
    assert_output "Test summary"
}

@test "parse_ai_response extracts Ollama response" {
    detect_json_tool
    local body='{"message":{"content":"Test summary"}}'
    run parse_ai_response "$body" "ollama"
    assert_success
    assert_output "Test summary"
}

@test "parse_ai_response returns empty on invalid JSON" {
    detect_json_tool
    run parse_ai_response "not json" "openai"
    assert_output ""
}

@test "parse_ai_response returns empty on wrong structure" {
    detect_json_tool
    run parse_ai_response '{"wrong":"structure"}' "openai"
    assert_output ""
}

# --- ai_summarize error paths ---

@test "ai_summarize fails when no config exists" {
    run ai_summarize
    assert_failure
    assert_output --partial "No AI config found"
}

@test "ai_summarize fails with missing OpenAI API key" {
    mkdir -p "$HOME/.config/yesterday"
    echo "AI_PROVIDER=openai" > "$HOME/.config/yesterday/config"

    run ai_summarize
    assert_failure
    assert_output --partial "No API key set for OpenAI"
}

@test "ai_summarize fails with missing Claude API key" {
    mkdir -p "$HOME/.config/yesterday"
    echo "AI_PROVIDER=claude" > "$HOME/.config/yesterday/config"

    run ai_summarize
    assert_failure
    assert_output --partial "No API key set for Claude"
}

@test "ai_summarize fails with missing Gemini API key" {
    mkdir -p "$HOME/.config/yesterday"
    echo "AI_PROVIDER=gemini" > "$HOME/.config/yesterday/config"

    run ai_summarize
    assert_failure
    assert_output --partial "No API key set for Gemini"
}

@test "ai_summarize fails with unknown provider" {
    mkdir -p "$HOME/.config/yesterday"
    echo "AI_PROVIDER=unknown" > "$HOME/.config/yesterday/config"

    run ai_summarize
    assert_failure
    assert_output --partial "Unknown AI provider"
}

@test "ai_summarize returns 0 when no commits found" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=openai
OPENAI_API_KEY=sk-test123
EOF

    cd "$REPO_DIR"
    # Build LOG_ARGS that will match no commits (far future date)
    LOG_ARGS=(--all --format="%h|%cd|%an|%s" --since="2099-01-01")

    run ai_summarize
    assert_success
    assert_output ""
}

# --- ai_summarize with mock curl ---

@test "ai_summarize shows line stats and summary on success" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=openai
OPENAI_API_KEY=sk-test123
OPENAI_MODEL=gpt-4o-mini
EOF

    make_commit "$REPO_DIR" "feat: add login page"
    make_commit "$REPO_DIR" "fix: resolve timeout"

    cd "$REPO_DIR"
    SHOW_ALL=true
    SHOW_ALL_TIME=true
    build_log_args ""

    # Mock curl to return a valid OpenAI response
    local mock_bin="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/curl" << 'MOCK'
#!/usr/bin/env bash
echo '{"choices":[{"message":{"content":"Added a login page and fixed a timeout issue."}}]}'
echo "200"
MOCK
    chmod +x "$mock_bin/curl"

    PATH="$mock_bin:$PATH" run ai_summarize
    assert_success
    assert_output --partial "lines"
    assert_output --partial "AI Summary"
    assert_output --partial "openai/gpt-4o-mini"
    assert_output --partial "Added a login page and fixed a timeout issue."
}

@test "ai_summarize shows error on non-200 status" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=openai
OPENAI_API_KEY=sk-badkey
EOF

    make_commit "$REPO_DIR" "some commit"

    cd "$REPO_DIR"
    SHOW_ALL=true
    SHOW_ALL_TIME=true
    build_log_args ""

    local mock_bin="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/curl" << 'MOCK'
#!/usr/bin/env bash
echo '{"error":{"message":"Invalid API key"}}'
echo "401"
MOCK
    chmod +x "$mock_bin/curl"

    PATH="$mock_bin:$PATH" run ai_summarize
    assert_failure
    assert_output --partial "AI request failed (401)"
}

@test "ai_summarize works with Claude provider" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=claude
CLAUDE_API_KEY=sk-ant-test
CLAUDE_MODEL=claude-sonnet-4-20250514
EOF

    make_commit "$REPO_DIR" "docs: update readme"

    cd "$REPO_DIR"
    SHOW_ALL=true
    SHOW_ALL_TIME=true
    build_log_args ""

    local mock_bin="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/curl" << 'MOCK'
#!/usr/bin/env bash
echo '{"content":[{"text":"Updated the project documentation."}]}'
echo "200"
MOCK
    chmod +x "$mock_bin/curl"

    PATH="$mock_bin:$PATH" run ai_summarize
    assert_success
    assert_output --partial "claude/claude-sonnet-4-20250514"
    assert_output --partial "Updated the project documentation."
}

@test "ai_summarize works with Gemini provider" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=gemini
GEMINI_API_KEY=AIza-test
GEMINI_MODEL=gemini-2.0-flash
EOF

    make_commit "$REPO_DIR" "feat: add search"

    cd "$REPO_DIR"
    SHOW_ALL=true
    SHOW_ALL_TIME=true
    build_log_args ""

    local mock_bin="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/curl" << 'MOCK'
#!/usr/bin/env bash
echo '{"candidates":[{"content":{"parts":[{"text":"Added search functionality."}]}}]}'
echo "200"
MOCK
    chmod +x "$mock_bin/curl"

    PATH="$mock_bin:$PATH" run ai_summarize
    assert_success
    assert_output --partial "gemini/gemini-2.0-flash"
    assert_output --partial "Added search functionality."
}

@test "ai_summarize works with Ollama provider" {
    mkdir -p "$HOME/.config/yesterday"
    cat > "$HOME/.config/yesterday/config" << 'EOF'
AI_PROVIDER=ollama
OLLAMA_MODEL=llama3.2
EOF

    make_commit "$REPO_DIR" "refactor: clean up auth"

    cd "$REPO_DIR"
    SHOW_ALL=true
    SHOW_ALL_TIME=true
    build_log_args ""

    local mock_bin="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/curl" << 'MOCK'
#!/usr/bin/env bash
echo '{"message":{"content":"Cleaned up the authentication code."}}'
echo "200"
MOCK
    chmod +x "$mock_bin/curl"

    PATH="$mock_bin:$PATH" run ai_summarize
    assert_success
    assert_output --partial "ollama/llama3.2"
    assert_output --partial "Cleaned up the authentication code."
}
