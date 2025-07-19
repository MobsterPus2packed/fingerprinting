#!/bin/bash
# Utility functions for cross-platform compatibility and common operations

# OS detection
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        FreeBSD*)   echo "freebsd" ;;
        OpenBSD*)   echo "openbsd" ;;
        NetBSD*)    echo "netbsd" ;;
        *)          echo "unknown" ;;
    esac
}

# Get the current OS
get_os() {
    if [[ -z "${DETECTED_OS:-}" ]]; then
        DETECTED_OS=$(detect_os)
    fi
    echo "$DETECTED_OS"
}

# Cross-platform file operations
create_directory() {
    local dir="$1"
    local mode="${2:-755}"
    
    if [[ "$(get_os)" == "windows" ]]; then
        mkdir -p "$dir" 2>/dev/null || return 1
    else
        mkdir -p "$dir" && chmod "$mode" "$dir"
    fi
}

remove_directory() {
    local dir="$1"
    local force="${2:-false}"
    
    if [[ ! -d "$dir" ]]; then
        return 0
    fi
    
    if [[ "$force" == "true" ]]; then
        if [[ "$(get_os)" == "windows" ]]; then
            rm -rf "$dir" 2>/dev/null || rmdir /s /q "$dir" 2>/dev/null
        else
            rm -rf "$dir"
        fi
    else
        rmdir "$dir" 2>/dev/null
    fi
}

# Cross-platform file copying
copy_file() {
    local src="$1"
    local dest="$2"
    local preserve_attrs="${3:-true}"
    
    if [[ "$(get_os)" == "windows" ]]; then
        cp "$src" "$dest"
    elif [[ "$preserve_attrs" == "true" ]]; then
        cp -p "$src" "$dest"
    else
        cp "$src" "$dest"
    fi
}

# Cross-platform file permissions
set_executable() {
    local file="$1"
    
    if [[ "$(get_os)" != "windows" ]]; then
        chmod +x "$file"
    fi
}

# Path handling
normalize_path() {
    local path="$1"
    
    # Convert Windows paths if needed
    if [[ "$(get_os)" == "windows" ]]; then
        echo "$path" | sed 's|\\|/|g'
    else
        echo "$path"
    fi
}

# Check if command exists
command_exists() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# Get command with fallbacks for cross-platform compatibility
get_command() {
    local cmd_name="$1"
    shift
    local fallbacks=("$@")
    
    if command_exists "$cmd_name"; then
        echo "$cmd_name"
        return 0
    fi
    
    for fallback in "${fallbacks[@]}"; do
        if command_exists "$fallback"; then
            echo "$fallback"
            return 0
        fi
    done
    
    return 1
}

# Safe file replacement with backup
safe_replace_file() {
    local source="$1"
    local target="$2"
    local backup_dir="${3:-./backups}"
    
    if [[ -f "$target" ]]; then
        create_directory "$backup_dir"
        local backup_file="$backup_dir/$(basename "$target").$(date +%s).bak"
        copy_file "$target" "$backup_file"
    fi
    
    copy_file "$source" "$target"
}

# Cleanup function for temporary files
cleanup_temp_files() {
    local temp_prefix="${1:-crex_deploy_tmp}"
    
    # Remove temporary files created by this script
    find /tmp -name "${temp_prefix}*" -type f -mtime +1 -delete 2>/dev/null || true
    
    # Clean up any lock files
    rm -f "/tmp/${temp_prefix}.lock" 2>/dev/null || true
}

# File lock mechanism
acquire_lock() {
    local lock_file="${1:-/tmp/crex_deploy.lock}"
    local timeout="${2:-30}"
    local count=0
    
    while [[ $count -lt $timeout ]]; do
        if (set -C; echo $$ > "$lock_file") 2>/dev/null; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    return 1
}

release_lock() {
    local lock_file="${1:-/tmp/crex_deploy.lock}"
    rm -f "$lock_file" 2>/dev/null || true
}

# URL validation
validate_url() {
    local url="$1"
    
    # Basic URL validation
    if [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
        return 0
    elif [[ "$url" =~ ^git@[a-zA-Z0-9.-]+:[a-zA-Z0-9._/-]+\.git$ ]]; then
        return 0
    else
        return 1
    fi
}

# Network connectivity check
check_network() {
    local host="${1:-github.com}"
    local timeout="${2:-5}"
    
    if command_exists ping; then
        if [[ "$(get_os)" == "macos" ]]; then
            ping -c 1 -t "$timeout" "$host" >/dev/null 2>&1
        else
            ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
        fi
    elif command_exists curl; then
        curl -s --connect-timeout "$timeout" "https://$host" >/dev/null 2>&1
    elif command_exists wget; then
        wget -q --timeout="$timeout" --spider "https://$host" >/dev/null 2>&1
    else
        return 1
    fi
}

# Simple string encryption/decryption for local storage
simple_encrypt() {
    local input="$1"
    local key="${2:-crex_default_key}"
    
    echo "$input" | openssl enc -aes-256-cbc -a -salt -k "$key" 2>/dev/null || echo "$input"
}

simple_decrypt() {
    local input="$1"
    local key="${2:-crex_default_key}"
    
    echo "$input" | openssl enc -aes-256-cbc -d -a -k "$key" 2>/dev/null || echo "$input"
}

# Check if running in CI/CD environment
is_ci_environment() {
    [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${JENKINS_URL:-}" ]] || [[ -n "${GITLAB_CI:-}" ]]
}

# Get system information
get_system_info() {
    echo "OS: $(get_os)"
    echo "Shell: ${SHELL##*/}"
    echo "User: $(whoami)"
    echo "PWD: $(pwd)"
    echo "Date: $(date)"
    if command_exists git; then
        echo "Git: $(git --version 2>/dev/null || echo 'Not available')"
    fi
}