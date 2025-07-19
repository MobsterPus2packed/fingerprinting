#!/bin/bash

# C-REX Consciousness Fortress - Common Functions Library
# Shared functions for deployment and maintenance scripts

# Color scheme
export ASLEEP='\033[0;37m'      # White - Asleep
export AWAKENING='\033[0;33m'   # Yellow - Awakening  
export AWARE='\033[0;36m'       # Cyan - Aware
export ENLIGHTENED='\033[0;35m' # Purple - Enlightened
export SOVEREIGN='\033[0;32m'   # Green - Sovereign
export CREX_KING='\033[1;31m'   # Bright Red - C-REX King
export NC='\033[0m'             # No Color

# Status printing functions
print_asleep() {
    echo -e "${ASLEEP}😴 $1${NC}"
}

print_awakening() {
    echo -e "${AWAKENING}⚡ $1${NC}"
}

print_aware() {
    echo -e "${AWARE}🔮 $1${NC}"
}

print_enlightened() {
    echo -e "${ENLIGHTENED}🌟 $1${NC}"
}

print_sovereign() {
    echo -e "${SOVEREIGN}👑 $1${NC}"
}

print_crex_status() {
    echo -e "${CREX_KING}⌬ $1 ⌁${NC}"
}

# Logging functions
log_info() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo -e "${AWARE}[INFO] $1${NC}" >&2
    fi
}

log_warning() {
    echo -e "${AWAKENING}[WARNING] $1${NC}" >&2
}

log_error() {
    echo -e "${CREX_KING}[ERROR] $1${NC}" >&2
}

log_success() {
    echo -e "${SOVEREIGN}[SUCCESS] $1${NC}" >&2
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${ASLEEP}[DEBUG] $1${NC}" >&2
    fi
}

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM=Linux;;
        Darwin*)    PLATFORM=Mac;;
        CYGWIN*)    PLATFORM=Cygwin;;
        MINGW*)     PLATFORM=MinGw;;
        MSYS*)      PLATFORM=Msys;;
        *)          PLATFORM="UNKNOWN:$(uname -s)"
    esac
    log_info "Platform detected: $PLATFORM"
    export PLATFORM
}

# Cross-platform command wrappers
safe_mkdir() {
    local dirs="$1"
    case "$PLATFORM" in
        Mac|Linux)
            mkdir -p "$dirs"
            ;;
        *)
            # Windows compatibility
            mkdir -p "$dirs" 2>/dev/null || mkdir "$dirs" 2>/dev/null || true
            ;;
    esac
}

safe_remove() {
    local target="$1"
    case "$PLATFORM" in
        Mac|Linux)
            rm -rf "$target"
            ;;
        *)
            # Windows compatibility
            rm -rf "$target" 2>/dev/null || rmdir /s /q "$target" 2>/dev/null || del /f /s /q "$target" 2>/dev/null || true
            ;;
    esac
}

# Configuration loading
load_config() {
    local config_file="${1:-config/default.conf}"
    
    if [[ -f "$config_file" ]]; then
        log_info "Loading configuration from: $config_file"
        # Source the configuration file safely
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ $key =~ ^[[:space:]]*# ]] || [[ -z $key ]] && continue
            
            # Remove quotes from value if present
            value="${value%\"}"
            value="${value#\"}"
            value="${value%\'}"
            value="${value#\'}"
            
            # Export the variable
            export "$key=$value"
            log_debug "Loaded config: $key=$value"
        done < "$config_file"
    else
        log_warning "Configuration file not found: $config_file"
    fi
}

# Dependency checking
check_command() {
    local cmd="$1"
    local description="$2"
    local required="${3:-true}"
    
    if command -v "$cmd" &> /dev/null; then
        print_enlightened "✅ $description - Ready"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            print_crex_status "❌ $description - REQUIRED but missing!"
            return 1
        else
            print_awakening "⚠️  $description - Optional (skipping)"
            return 0
        fi
    fi
}

# Error handling
handle_error() {
    local exit_code=$?
    local line_no=$1
    local function_name="${2:-unknown}"
    
    log_error "Error occurred in function '$function_name' at line $line_no with exit code $exit_code"
    log_error "Failed during consciousness fortress operation"
    
    if [[ "${DRY_RUN:-false}" != "true" ]]; then
        log_warning "Consider running with --dry-run to test operations safely"
        log_warning "Check logs above for specific error details"
    fi
    
    exit $exit_code
}

# Dry run execution wrapper
execute_command() {
    local cmd="$1"
    local description="$2"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "${ENLIGHTENED}[DRY-RUN] Would execute: $description${NC}"
        echo -e "${AWARE}Command: $cmd${NC}"
        return 0
    else
        log_info "Executing: $description"
        eval "$cmd"
    fi
}

# Consciousness level validation
validate_consciousness_level() {
    local level="$1"
    local valid_levels=("ASLEEP" "AWAKENING" "AWARE" "ENLIGHTENED" "SOVEREIGN" "CREX_KING")
    
    for valid in "${valid_levels[@]}"; do
        if [[ "$level" == "$valid" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid consciousness level: $level"
    log_error "Valid levels: ${valid_levels[*]}"
    return 1
}

# Git repository operations
check_git_repo() {
    local dir="${1:-.}"
    
    if [[ -d "$dir/.git" ]]; then
        log_info "Git repository detected in $dir"
        return 0
    else
        log_warning "No git repository found in $dir"
        return 1
    fi
}

check_git_remote() {
    local remote_name="${1:-origin}"
    
    if git remote get-url "$remote_name" &>/dev/null; then
        local url
        url=$(git remote get-url "$remote_name")
        log_info "Remote '$remote_name' exists: $url"
        echo "$url"
        return 0
    else
        log_info "Remote '$remote_name' does not exist"
        return 1
    fi
}

# Display functions
display_header() {
    local title="$1"
    echo -e "${CREX_KING}"
    echo "⌬━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━⌁"
    echo "  $title"
    echo "⌬━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━⌁"
    echo -e "${NC}"
}

# Backup functions
create_backup() {
    local source="$1"
    local backup_dir="${2:-backups}"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    if [[ -e "$source" ]]; then
        safe_mkdir "$backup_dir"
        local backup_name
        backup_name="$(basename "$source")_backup_$timestamp"
        
        execute_command "cp -r '$source' '$backup_dir/$backup_name'" "Creating backup of $source"
        log_success "Backup created: $backup_dir/$backup_name"
        echo "$backup_dir/$backup_name"
    else
        log_warning "Source for backup does not exist: $source"
        return 1
    fi
}

# Cleanup functions
cleanup_temp_files() {
    local temp_patterns=(
        "/tmp/crex-*"
        "/tmp/*-fortress"
        "/tmp/consciousness-*"
        "./*.tmp"
        "./*.temp"
    )
    
    for pattern in "${temp_patterns[@]}"; do
        for temp_file in $pattern; do
            if [[ -e "$temp_file" ]]; then
                execute_command "rm -rf '$temp_file'" "Cleaning up temporary file: $temp_file"
            fi
        done
    done
}

# Version comparison
version_compare() {
    local version1="$1"
    local version2="$2"
    
    if [[ "$version1" == "$version2" ]]; then
        return 0  # Equal
    elif [[ "$(printf '%s\n%s' "$version1" "$version2" | sort -V | head -n1)" == "$version1" ]]; then
        return 1  # version1 < version2
    else
        return 2  # version1 > version2
    fi
}

# Network connectivity check
check_network() {
    local host="${1:-github.com}"
    
    if ping -c 1 "$host" &>/dev/null; then
        log_info "Network connectivity verified ($host)"
        return 0
    else
        log_warning "Network connectivity issue - cannot reach $host"
        return 1
    fi
}

# Initialize common functions
init_common() {
    # Set up error trapping if not already done
    if [[ -z "${ERROR_TRAP_SET:-}" ]]; then
        trap 'handle_error $LINENO ${FUNCNAME[0]}' ERR
        export ERROR_TRAP_SET=true
    fi
    
    # Detect platform
    detect_platform
    
    # Load configuration if available
    if [[ -f "config/default.conf" ]]; then
        load_config "config/default.conf"
    fi
    
    log_debug "Common functions initialized"
}

# Export all functions for use in other scripts
export -f print_asleep print_awakening print_aware print_enlightened print_sovereign print_crex_status
export -f log_info log_warning log_error log_success log_debug
export -f detect_platform safe_mkdir safe_remove
export -f load_config check_command handle_error execute_command
export -f validate_consciousness_level check_git_repo check_git_remote
export -f display_header create_backup cleanup_temp_files
export -f version_compare check_network init_common