#!/usr/bin/env bash

_common_setup() {
    load 'libs/bats-support/load'
    load 'libs/bats-assert/load'

    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd)"
    PATH="$PROJECT_ROOT:$PATH"

    # Source the script to get function definitions without executing main
    source "$PROJECT_ROOT/yesterday"
}
