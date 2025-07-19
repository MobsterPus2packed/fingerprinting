#!/bin/bash
# Security and secrets handling functions

# Initialize secure environment
init_security() {
    log_info "Initializing security environment"
    
    # Set secure defaults
    umask 077  # Restrict file permissions
    
    # Clear sensitive environment variables that shouldn't be inherited
    unset GITHUB_TOKEN GITHUB_PASSWORD GIT_PASSWORD
    
    # Create secure temporary directory
    if [[ -z "${SECURE_TEMP_DIR:-}" ]]; then
        SECURE_TEMP_DIR=$(mktemp -d -t crex_secure_XXXXXX)
        chmod 700 "$SECURE_TEMP_DIR"
        log_debug "Created secure temp directory: $SECURE_TEMP_DIR"
    fi
}

# Cleanup security environment
cleanup_security() {
    log_debug "Cleaning up security environment"
    
    # Clear sensitive variables
    unset_sensitive_vars
    
    # Remove secure temp directory
    if [[ -n "${SECURE_TEMP_DIR:-}" ]] && [[ -d "$SECURE_TEMP_DIR" ]]; then
        rm -rf "$SECURE_TEMP_DIR"
        unset SECURE_TEMP_DIR
    fi
}

# Unset sensitive variables
unset_sensitive_vars() {
    local sensitive_vars=(
        "GITHUB_TOKEN"
        "GITHUB_PASSWORD"
        "GIT_PASSWORD"
        "API_KEY"
        "SECRET_KEY"
        "ACCESS_TOKEN"
        "PRIVATE_KEY"
        "SSH_KEY"
        "DATABASE_PASSWORD"
        "DEPLOYMENT_KEY"
    )
    
    for var in "${sensitive_vars[@]}"; do
        unset "$var" 2>/dev/null || true
    done
}

# Prompt for secret with masking
prompt_for_secret() {
    local prompt="$1"
    local var_name="$2"
    local default_value="${3:-}"
    local allow_empty="${4:-false}"
    
    if [[ "$PROMPT_FOR_SECRETS" != "true" ]]; then
        log_debug "Prompting for secrets disabled, checking environment"
        if [[ -n "${!var_name:-}" ]]; then
            log_debug "Using environment variable: $var_name"
            return 0
        elif [[ -n "$default_value" ]]; then
            declare -g "$var_name"="$default_value"
            log_debug "Using default value for: $var_name"
            return 0
        elif [[ "$allow_empty" == "true" ]]; then
            declare -g "$var_name"=""
            return 0
        else
            log_error "Required secret not found in environment: $var_name"
            return 1
        fi
    fi
    
    local secret_value=""
    
    echo -n "$prompt: "
    read -s secret_value
    echo  # New line after hidden input
    
    if [[ -z "$secret_value" ]]; then
        if [[ -n "$default_value" ]]; then
            secret_value="$default_value"
            log_debug "Using default value for secret: $var_name"
        elif [[ "$allow_empty" == "true" ]]; then
            log_debug "Empty secret allowed for: $var_name"
        else
            log_error "Secret cannot be empty: $var_name"
            return 1
        fi
    fi
    
    # Store in variable
    declare -g "$var_name"="$secret_value"
    log_debug "Secret stored in variable: $var_name"
    
    return 0
}

# Get secret from environment or prompt
get_secret() {
    local var_name="$1"
    local prompt="${2:-Enter $var_name}"
    local allow_empty="${3:-false}"
    
    # First try environment variables
    if [[ -n "${!var_name:-}" ]]; then
        log_debug "Using environment variable: $var_name"
        return 0
    fi
    
    # Try common alternative environment variable names
    local alt_names=(
        "${var_name^^}"  # Uppercase
        "${var_name,,}"  # Lowercase
        "CREX_${var_name^^}"
        "${var_name}_SECRET"
        "${var_name}_KEY"
    )
    
    for alt_name in "${alt_names[@]}"; do
        if [[ -n "${!alt_name:-}" ]]; then
            declare -g "$var_name"="${!alt_name}"
            log_debug "Using alternative environment variable: $alt_name -> $var_name"
            return 0
        fi
    done
    
    # Try loading from secure config file
    if load_secret_from_file "$var_name"; then
        return 0
    fi
    
    # Prompt if interactive and allowed
    if [[ "${INTERACTIVE:-false}" == "true" ]] && [[ -t 0 ]]; then
        prompt_for_secret "$prompt" "$var_name" "" "$allow_empty"
        return $?
    fi
    
    # Check if empty is allowed
    if [[ "$allow_empty" == "true" ]]; then
        declare -g "$var_name"=""
        log_debug "Empty secret allowed for: $var_name"
        return 0
    fi
    
    log_error "Secret not available and cannot prompt: $var_name"
    return 1
}

# Load secret from encrypted file
load_secret_from_file() {
    local var_name="$1"
    local secret_file="${SECRETS_DIR:-$HOME/.crex/secrets}/${var_name,,}.enc"
    
    if [[ ! -f "$secret_file" ]]; then
        log_debug "Secret file not found: $secret_file"
        return 1
    fi
    
    if ! command_exists openssl; then
        log_debug "OpenSSL not available for secret decryption"
        return 1
    fi
    
    # Try to decrypt the secret file
    local secret_key="${SECRET_ENCRYPTION_KEY:-crex_default_key}"
    local secret_value
    
    if secret_value=$(openssl enc -aes-256-cbc -d -a -in "$secret_file" -k "$secret_key" 2>/dev/null); then
        declare -g "$var_name"="$secret_value"
        log_debug "Loaded encrypted secret: $var_name"
        return 0
    else
        log_debug "Failed to decrypt secret file: $secret_file"
        return 1
    fi
}

# Save secret to encrypted file
save_secret_to_file() {
    local var_name="$1"
    local secret_value="${!var_name:-}"
    local secrets_dir="${SECRETS_DIR:-$HOME/.crex/secrets}"
    local secret_file="$secrets_dir/${var_name,,}.enc"
    
    if [[ -z "$secret_value" ]]; then
        log_error "No secret value to save for: $var_name"
        return 1
    fi
    
    if ! command_exists openssl; then
        log_error "OpenSSL not available for secret encryption"
        return 1
    fi
    
    # Create secrets directory
    create_directory "$secrets_dir" 700
    
    # Encrypt and save the secret
    local secret_key="${SECRET_ENCRYPTION_KEY:-crex_default_key}"
    
    if echo "$secret_value" | openssl enc -aes-256-cbc -a -out "$secret_file" -k "$secret_key" 2>/dev/null; then
        chmod 600 "$secret_file"
        log_info "Secret saved to encrypted file: $var_name"
        return 0
    else
        log_error "Failed to encrypt and save secret: $var_name"
        return 1
    fi
}

# Validate GitHub credentials
validate_github_credentials() {
    local test_repo="${1:-https://github.com/octocat/Hello-World.git}"
    
    log_info "Validating GitHub credentials"
    
    # Check if we have any authentication method
    if [[ -z "${GITHUB_TOKEN:-}" ]] && [[ -z "${GIT_USERNAME:-}" ]]; then
        if [[ "${INTERACTIVE:-false}" == "true" ]]; then
            echo "GitHub authentication required. Choose method:"
            echo "1) Personal Access Token (recommended)"
            echo "2) Username and Password"
            read -p "Choice (1-2): " auth_choice
            
            case "$auth_choice" in
                1)
                    prompt_for_secret "GitHub Personal Access Token" "GITHUB_TOKEN"
                    ;;
                2)
                    read -p "GitHub Username: " GIT_USERNAME
                    prompt_for_secret "GitHub Password" "GITHUB_PASSWORD"
                    ;;
                *)
                    log_error "Invalid authentication choice"
                    return 1
                    ;;
            esac
        else
            log_error "GitHub authentication required but not available"
            return 1
        fi
    fi
    
    # Test authentication by trying to access a public repository
    local git_cmd="git"
    local test_url="$test_repo"
    
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        # Use token authentication
        local auth_url=$(echo "$test_url" | sed "s|https://|https://${GITHUB_TOKEN}@|")
        log_debug "Testing GitHub token authentication"
    elif [[ -n "${GIT_USERNAME:-}" ]] && [[ -n "${GITHUB_PASSWORD:-}" ]]; then
        # Use username/password authentication
        local auth_url=$(echo "$test_url" | sed "s|https://|https://${GIT_USERNAME}:${GITHUB_PASSWORD}@|")
        log_debug "Testing GitHub username/password authentication"
    else
        # Try without authentication (public repo)
        local auth_url="$test_url"
        log_debug "Testing GitHub access without authentication"
    fi
    
    if git ls-remote "$auth_url" >/dev/null 2>&1; then
        log_info "GitHub credentials validated successfully"
        return 0
    else
        log_error "GitHub credential validation failed"
        return 1
    fi
}

# Setup git configuration with credentials
setup_git_credentials() {
    log_info "Setting up Git credentials"
    
    # Configure git if needed
    if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
        if [[ -n "${GIT_USERNAME:-}" ]]; then
            git config --global user.name "$GIT_USERNAME"
            log_debug "Set git user.name from GIT_USERNAME"
        else
            prompt_for_secret "Git Username" "GIT_USERNAME" "$(whoami)" true
            git config --global user.name "$GIT_USERNAME"
        fi
    fi
    
    if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
        if [[ -n "${GIT_EMAIL:-}" ]]; then
            git config --global user.email "$GIT_EMAIL"
            log_debug "Set git user.email from GIT_EMAIL"
        else
            local default_email="${GIT_USERNAME:-$(whoami)}@$(hostname)"
            prompt_for_secret "Git Email" "GIT_EMAIL" "$default_email" true
            git config --global user.email "$GIT_EMAIL"
        fi
    fi
    
    # Setup credential helper if token is available
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        # Create a credential helper script
        local cred_helper="$SECURE_TEMP_DIR/git-credential-helper"
        cat > "$cred_helper" << EOF
#!/bin/bash
echo "username=\${GITHUB_TOKEN}"
echo "password="
EOF
        chmod 700 "$cred_helper"
        git config --global credential.helper "$cred_helper"
        log_debug "Configured git credential helper for token authentication"
    fi
}

# Generate secure configuration
generate_secure_config() {
    local config_file="$1"
    local template_file="${2:-}"
    
    log_info "Generating secure configuration: $config_file"
    
    # Create config directory
    local config_dir=$(dirname "$config_file")
    create_directory "$config_dir" 750
    
    # Start with template if provided
    if [[ -n "$template_file" ]] && [[ -f "$template_file" ]]; then
        copy_file "$template_file" "$config_file"
    else
        touch "$config_file"
    fi
    
    chmod 640 "$config_file"
    
    # Add security headers
    cat >> "$config_file" << EOF

# Security Configuration Generated: $(date)
# WARNING: This file may contain sensitive information
# Ensure proper file permissions are maintained

EOF
    
    log_debug "Secure configuration generated: $config_file"
}

# Audit security settings
audit_security() {
    log_info "Performing security audit"
    
    local issues=()
    
    # Check file permissions
    if [[ -f "$LOG_FILE" ]] && [[ "$(stat -c %a "$LOG_FILE" 2>/dev/null || stat -f %p "$LOG_FILE" 2>/dev/null)" != "600" ]]; then
        issues+=("Log file permissions too permissive: $LOG_FILE")
    fi
    
    # Check for sensitive data in environment
    local sensitive_patterns=("password" "token" "key" "secret")
    for pattern in "${sensitive_patterns[@]}"; do
        if env | grep -i "$pattern" >/dev/null 2>&1; then
            issues+=("Sensitive environment variables detected")
            break
        fi
    done
    
    # Check secure temp directory
    if [[ -n "${SECURE_TEMP_DIR:-}" ]] && [[ -d "$SECURE_TEMP_DIR" ]]; then
        local temp_perms=$(stat -c %a "$SECURE_TEMP_DIR" 2>/dev/null || stat -f %p "$SECURE_TEMP_DIR" 2>/dev/null)
        if [[ "$temp_perms" != "700" ]]; then
            issues+=("Secure temp directory permissions incorrect: $SECURE_TEMP_DIR")
        fi
    fi
    
    # Report issues
    if [[ ${#issues[@]} -gt 0 ]]; then
        log_warn "Security audit found issues:"
        for issue in "${issues[@]}"; do
            log_warn "  - $issue"
        done
        return 1
    else
        log_info "Security audit passed"
        return 0
    fi
}