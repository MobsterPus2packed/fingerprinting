#!/bin/bash
# Logging and error handling functions

# Initialize logging system
init_logging() {
    local log_dir="${LOG_DIR:-./logs}"
    local log_level="${LOG_LEVEL:-INFO}"
    
    # Create log directory
    mkdir -p "$log_dir"
    
    # Set global log file
    LOG_FILE="${log_dir}/crex_deploy_$(date +%Y%m%d_%H%M%S).log"
    
    # Set log level
    case "$log_level" in
        DEBUG) LOG_LEVEL_NUM=0 ;;
        INFO)  LOG_LEVEL_NUM=1 ;;
        WARN)  LOG_LEVEL_NUM=2 ;;
        ERROR) LOG_LEVEL_NUM=3 ;;
        *)     LOG_LEVEL_NUM=1 ;;
    esac
    
    # Initialize log file
    echo "=== C-REX Deployment Log Started ===" > "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    echo "Script: $0" >> "$LOG_FILE"
    echo "Args: $*" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
}

# Core logging function
write_log() {
    local level="$1"
    local message="$2"
    local mask_sensitive="${MASK_SENSITIVE:-true}"
    
    # Assign numeric level
    local level_num
    case "$level" in
        DEBUG) level_num=0 ;;
        INFO)  level_num=1 ;;
        WARN)  level_num=2 ;;
        ERROR) level_num=3 ;;
        *)     level_num=1 ;;
    esac
    
    # Check if we should log this level
    if [[ $level_num -lt ${LOG_LEVEL_NUM:-1} ]]; then
        return 0
    fi
    
    # Mask sensitive information if enabled
    if [[ "$mask_sensitive" == "true" ]]; then
        message=$(mask_sensitive_info "$message")
    fi
    
    # Format log entry
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    # Write to log file if available
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "$log_entry" >> "$LOG_FILE"
    fi
    
    # Also write to stderr for errors
    if [[ "$level" == "ERROR" ]]; then
        echo "$log_entry" >&2
    fi
}

# Convenience logging functions
log_debug() {
    write_log "DEBUG" "$1"
}

log_info() {
    write_log "INFO" "$1"
}

log_warn() {
    write_log "WARN" "$1"
}

log_error() {
    write_log "ERROR" "$1"
}

# Mask sensitive information in logs
mask_sensitive_info() {
    local text="$1"
    
    # Mask common sensitive patterns
    text=$(echo "$text" | sed -E 's|(token[[:space:]]*[:=][[:space:]]*)([a-zA-Z0-9_-]{8,})|\1***MASKED***|gi')
    text=$(echo "$text" | sed -E 's|(password[[:space:]]*[:=][[:space:]]*)([^[:space:]]+)|\1***MASKED***|gi')
    text=$(echo "$text" | sed -E 's|(key[[:space:]]*[:=][[:space:]]*)([a-zA-Z0-9_-]{8,})|\1***MASKED***|gi')
    text=$(echo "$text" | sed -E 's|(secret[[:space:]]*[:=][[:space:]]*)([^[:space:]]+)|\1***MASKED***|gi')
    text=$(echo "$text" | sed -E 's|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|***EMAIL_MASKED***|g')
    text=$(echo "$text" | sed -E 's|(https?://[^:]+:)([^@]+)(@)|\1***MASKED***\3|g')
    
    echo "$text"
}

# Error handling with stack trace
handle_error() {
    local exit_code="${1:-1}"
    local error_message="${2:-Unknown error occurred}"
    local line_number="${3:-unknown}"
    
    log_error "Error on line $line_number: $error_message (exit code: $exit_code)"
    
    # Print stack trace in debug mode
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        log_debug "Call stack:"
        local frame=0
        while caller $frame; do
            ((frame++))
        done | while read line func file; do
            log_debug "  $file:$line in function $func"
        done
    fi
    
    # Cleanup on error
    cleanup_on_error
    
    exit "$exit_code"
}

# Cleanup function called on errors
cleanup_on_error() {
    log_info "Performing cleanup after error..."
    
    # Release any locks
    release_lock
    
    # Clean up temporary files
    cleanup_temp_files
    
    # Run custom cleanup if defined
    if declare -f custom_cleanup >/dev/null; then
        custom_cleanup
    fi
}

# Progress tracking
init_progress() {
    PROGRESS_TOTAL="${1:-100}"
    PROGRESS_CURRENT=0
    PROGRESS_START_TIME=$(date +%s)
}

update_progress() {
    local current="$1"
    local message="${2:-Processing...}"
    
    PROGRESS_CURRENT="$current"
    
    if [[ "${SHOW_PROGRESS:-true}" == "true" ]] && [[ ${PROGRESS_TOTAL:-1} -gt 0 ]]; then
        local percent=$((current * 100 / PROGRESS_TOTAL))
        local bar_length=50
        local filled_length=$((percent * bar_length / 100))
        
        # Create progress bar
        local bar=""
        for ((i=0; i<filled_length; i++)); do
            bar+="█"
        done
        for ((i=filled_length; i<bar_length; i++)); do
            bar+="░"
        done
        
        # Calculate ETA
        local elapsed=$(($(date +%s) - PROGRESS_START_TIME))
        local eta=""
        if [[ $current -gt 0 && $elapsed -gt 0 ]]; then
            local remaining_time=$(( (PROGRESS_TOTAL - current) * elapsed / current ))
            eta=" ETA: ${remaining_time}s"
        fi
        
        printf "\r[%s] %3d%% %s%s" "$bar" "$percent" "$message" "$eta"
        
        if [[ $current -eq $PROGRESS_TOTAL ]]; then
            echo  # New line when complete
        fi
    fi
    
    log_debug "Progress: $current/$PROGRESS_TOTAL - $message"
}

# Validation functions
validate_required_vars() {
    local vars=("$@")
    local missing=()
    
    for var in "${vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing+=("$var")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required variables: ${missing[*]}"
        return 1
    fi
}

validate_file_exists() {
    local file="$1"
    local description="${2:-File}"
    
    if [[ ! -f "$file" ]]; then
        log_error "$description does not exist: $file"
        return 1
    fi
}

validate_directory_exists() {
    local dir="$1"
    local description="${2:-Directory}"
    
    if [[ ! -d "$dir" ]]; then
        log_error "$description does not exist: $dir"
        return 1
    fi
}

# Remote repository validation
validate_remote_repo() {
    local repo_url="$1"
    local timeout="${2:-10}"
    
    log_info "Validating remote repository: $repo_url"
    
    # Basic URL validation
    if ! validate_url "$repo_url"; then
        log_error "Invalid repository URL format: $repo_url"
        return 1
    fi
    
    # Check network connectivity
    local host
    if [[ "$repo_url" =~ ^https?://([^/]+) ]]; then
        host="${BASH_REMATCH[1]}"
    elif [[ "$repo_url" =~ ^git@([^:]+): ]]; then
        host="${BASH_REMATCH[1]}"
    else
        log_error "Cannot extract host from URL: $repo_url"
        return 1
    fi
    
    if ! check_network "$host" "$timeout"; then
        log_error "Cannot reach repository host: $host"
        return 1
    fi
    
    # Test repository accessibility
    log_debug "Testing repository accessibility..."
    local temp_dir=$(mktemp -d)
    if git ls-remote "$repo_url" >/dev/null 2>&1; then
        log_info "Remote repository is accessible"
        return 0
    else
        log_error "Remote repository is not accessible or does not exist: $repo_url"
        return 1
    fi
}

# Set up error trapping
setup_error_handling() {
    set -eE  # Exit on error and inherit ERR trap
    
    # Trap errors and handle them
    trap 'handle_error $? "Command failed" $LINENO' ERR
    
    # Trap exit to cleanup
    trap 'cleanup_on_error' EXIT
    
    # Trap interrupts
    trap 'log_info "Script interrupted by user"; cleanup_on_error; exit 130' INT TERM
}

# Disable error handling (for cleanup functions)
disable_error_handling() {
    set +eE
    trap - ERR EXIT INT TERM
}