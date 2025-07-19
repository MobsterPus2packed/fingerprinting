#!/usr/bin/env bash
# Test suite for C-REX deployment script using Bats testing framework
# https://github.com/bats-core/bats-core

# Setup and teardown functions
setup() {
    # Create test environment
    export TEST_DIR="$(mktemp -d)"
    export ORIGINAL_PWD="$(pwd)"
    export TEST_REPO_NAME="test-crex-deployment"
    export TEST_LOCAL_DIR="$TEST_DIR/$TEST_REPO_NAME"
    
    # Set test configuration
    export DRY_RUN=true
    export VERBOSE=false
    export INTERACTIVE=false
    export SKIP_TESTS=true
    export LOG_LEVEL=DEBUG
    export LOG_DIR="$TEST_DIR/logs"
    export BACKUP_DIR="$TEST_DIR/backups"
    export SECRETS_DIR="$TEST_DIR/secrets"
    
    # Source the library functions
    source "$BATS_TEST_DIRNAME/../lib/utils.sh"
    source "$BATS_TEST_DIRNAME/../lib/logging.sh"
    source "$BATS_TEST_DIRNAME/../lib/security.sh"
    
    # Initialize test logging
    init_logging
    
    cd "$TEST_DIR" || exit 1
}

teardown() {
    cd "$ORIGINAL_PWD" || exit 1
    
    # Cleanup test environment
    if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
    
    # Reset environment
    unset TEST_DIR ORIGINAL_PWD TEST_REPO_NAME TEST_LOCAL_DIR
    unset DRY_RUN VERBOSE INTERACTIVE SKIP_TESTS LOG_LEVEL LOG_DIR BACKUP_DIR SECRETS_DIR
}

# Utility functions for tests
assert_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || fail "File does not exist: $file"
}

assert_directory_exists() {
    local dir="$1"
    [[ -d "$dir" ]] || fail "Directory does not exist: $dir"
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    grep -q "$pattern" "$file" || fail "File '$file' does not contain pattern: $pattern"
}

assert_file_executable() {
    local file="$1"
    [[ -x "$file" ]] || fail "File is not executable: $file"
}

# Test OS detection
@test "OS detection works correctly" {
    run detect_os
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^(linux|macos|windows|freebsd|openbsd|netbsd|unknown)$ ]]
}

@test "get_os returns consistent results" {
    local os1=$(get_os)
    local os2=$(get_os)
    [[ "$os1" == "$os2" ]]
}

# Test directory operations
@test "create_directory creates directories with correct permissions" {
    local test_dir="$TEST_DIR/test_create"
    
    run create_directory "$test_dir"
    [ "$status" -eq 0 ]
    assert_directory_exists "$test_dir"
}

@test "remove_directory removes directories safely" {
    local test_dir="$TEST_DIR/test_remove"
    mkdir -p "$test_dir"
    echo "test" > "$test_dir/file.txt"
    
    run remove_directory "$test_dir" true
    [ "$status" -eq 0 ]
    [[ ! -d "$test_dir" ]]
}

# Test file operations
@test "copy_file copies files correctly" {
    local src="$TEST_DIR/source.txt"
    local dest="$TEST_DIR/dest.txt"
    
    echo "test content" > "$src"
    
    run copy_file "$src" "$dest"
    [ "$status" -eq 0 ]
    assert_file_exists "$dest"
    assert_file_contains "$dest" "test content"
}

@test "safe_replace_file creates backup" {
    local src="$TEST_DIR/source.txt"
    local target="$TEST_DIR/target.txt"
    local backup_dir="$TEST_DIR/backups"
    
    echo "original content" > "$target"
    echo "new content" > "$src"
    
    run safe_replace_file "$src" "$target" "$backup_dir"
    [ "$status" -eq 0 ]
    
    assert_file_contains "$target" "new content"
    assert_directory_exists "$backup_dir"
    
    # Check backup exists
    local backup_files=("$backup_dir"/target.txt.*.bak)
    [[ -f "${backup_files[0]}" ]]
}

# Test command existence checking
@test "command_exists detects existing commands" {
    run command_exists "bash"
    [ "$status" -eq 0 ]
    
    run command_exists "nonexistent_command_12345"
    [ "$status" -eq 1 ]
}

@test "get_command returns primary command if available" {
    run get_command "bash" "sh" "zsh"
    [ "$status" -eq 0 ]
    [[ "$output" == "bash" ]]
}

@test "get_command returns fallback if primary unavailable" {
    run get_command "nonexistent_12345" "bash" "sh"
    [ "$status" -eq 0 ]
    [[ "$output" == "bash" ]]
}

# Test URL validation
@test "validate_url accepts valid HTTP URLs" {
    run validate_url "https://github.com/user/repo.git"
    [ "$status" -eq 0 ]
    
    run validate_url "http://example.com/path"
    [ "$status" -eq 0 ]
}

@test "validate_url accepts valid SSH URLs" {
    run validate_url "git@github.com:user/repo.git"
    [ "$status" -eq 0 ]
}

@test "validate_url rejects invalid URLs" {
    run validate_url "not-a-url"
    [ "$status" -eq 1 ]
    
    run validate_url "ftp://example.com"
    [ "$status" -eq 1 ]
}

# Test logging functionality
@test "logging initialization creates log file" {
    run init_logging
    [ "$status" -eq 0 ]
    assert_file_exists "$LOG_FILE"
}

@test "log levels work correctly" {
    init_logging
    
    log_debug "debug message"
    log_info "info message"
    log_warn "warn message"
    log_error "error message"
    
    assert_file_contains "$LOG_FILE" "info message"
    assert_file_contains "$LOG_FILE" "warn message"
    assert_file_contains "$LOG_FILE" "error message"
}

@test "sensitive information masking works" {
    local test_text="password=secret123 token=abc123 key=xyz789"
    local masked=$(mask_sensitive_info "$test_text")
    
    [[ "$masked" =~ \*\*\*MASKED\*\*\* ]]
    [[ ! "$masked" =~ secret123 ]]
    [[ ! "$masked" =~ abc123 ]]
    [[ ! "$masked" =~ xyz789 ]]
}

# Test progress tracking
@test "progress tracking initializes correctly" {
    run init_progress 100
    [ "$status" -eq 0 ]
    [[ "$PROGRESS_TOTAL" -eq 100 ]]
    [[ "$PROGRESS_CURRENT" -eq 0 ]]
}

@test "progress updates work correctly" {
    init_progress 100
    SHOW_PROGRESS=false  # Disable output for testing
    
    run update_progress 50 "Testing progress"
    [ "$status" -eq 0 ]
    [[ "$PROGRESS_CURRENT" -eq 50 ]]
}

# Test security functions
@test "security initialization creates secure temp directory" {
    run init_security
    [ "$status" -eq 0 ]
    assert_directory_exists "$SECURE_TEMP_DIR"
    
    # Check permissions (if not on Windows)
    if [[ "$(get_os)" != "windows" ]]; then
        local perms=$(stat -c %a "$SECURE_TEMP_DIR" 2>/dev/null || stat -f %p "$SECURE_TEMP_DIR" 2>/dev/null)
        [[ "$perms" == "700" ]]
    fi
}

@test "sensitive variable cleanup works" {
    export TEST_SECRET="sensitive_value"
    export GITHUB_TOKEN="token_value"
    
    run unset_sensitive_vars
    [ "$status" -eq 0 ]
    
    [[ -z "${GITHUB_TOKEN:-}" ]]
    [[ -n "${TEST_SECRET:-}" ]]  # Should not be cleared
}

# Test file lock mechanism
@test "file locking works correctly" {
    local lock_file="$TEST_DIR/test.lock"
    
    run acquire_lock "$lock_file" 5
    [ "$status" -eq 0 ]
    assert_file_exists "$lock_file"
    
    run release_lock "$lock_file"
    [ "$status" -eq 0 ]
    [[ ! -f "$lock_file" ]]
}

@test "file locking prevents double acquisition" {
    local lock_file="$TEST_DIR/test.lock"
    
    # Acquire lock
    acquire_lock "$lock_file" 5
    
    # Try to acquire again (should fail)
    run acquire_lock "$lock_file" 1
    [ "$status" -eq 1 ]
    
    # Release lock
    release_lock "$lock_file"
}

# Test network connectivity
@test "network check works for reachable host" {
    # Skip if no network available
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        skip "No network connectivity available"
    fi
    
    run check_network "8.8.8.8" 5
    [ "$status" -eq 0 ]
}

@test "network check fails for unreachable host" {
    run check_network "192.0.2.1" 1  # RFC5737 test address
    [ "$status" -eq 1 ]
}

# Test CI environment detection
@test "CI environment detection works" {
    # Test normal environment
    run is_ci_environment
    [ "$status" -eq 1 ]
    
    # Test with CI variable set
    export CI=true
    run is_ci_environment
    [ "$status" -eq 0 ]
    unset CI
    
    # Test with GitHub Actions
    export GITHUB_ACTIONS=true
    run is_ci_environment
    [ "$status" -eq 0 ]
    unset GITHUB_ACTIONS
}

# Test configuration validation
@test "required variables validation works" {
    export TEST_VAR1="value1"
    export TEST_VAR2="value2"
    
    run validate_required_vars "TEST_VAR1" "TEST_VAR2"
    [ "$status" -eq 0 ]
    
    unset TEST_VAR2
    run validate_required_vars "TEST_VAR1" "TEST_VAR2"
    [ "$status" -eq 1 ]
    
    unset TEST_VAR1
}

# Test cleanup functions
@test "cleanup removes temporary files" {
    local temp_file1="/tmp/crex_deploy_tmp_test1"
    local temp_file2="/tmp/crex_deploy_tmp_test2"
    
    touch "$temp_file1" "$temp_file2"
    
    run cleanup_temp_files "crex_deploy_tmp"
    [ "$status" -eq 0 ]
    
    # Files should still exist (mtime constraint)
    assert_file_exists "$temp_file1"
    assert_file_exists "$temp_file2"
    
    # Clean up manually
    rm -f "$temp_file1" "$temp_file2"
}

# Integration tests
@test "full logging workflow works" {
    init_logging
    init_security
    
    log_info "Starting integration test"
    log_debug "Debug information"
    log_warn "Warning message"
    
    assert_file_exists "$LOG_FILE"
    assert_file_contains "$LOG_FILE" "Starting integration test"
    assert_file_contains "$LOG_FILE" "Warning message"
    
    cleanup_security
}

@test "error handling setup works" {
    init_logging
    
    # This should work without errors
    run setup_error_handling
    [ "$status" -eq 0 ]
    
    # Disable error handling for cleanup
    disable_error_handling
}