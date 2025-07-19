#!/bin/bash
# C-REX ONE DRAW REVERSAL UNIT - ENHANCED DEPLOYMENT SCRIPT
# Phase Shift Lock Ion Protocol - Master Anti-Surveillance System
# Author: Cato Johansen (Darkbot) - C-REX Sovereign Systems
# Version: 3.0.0 - THE ENHANCED FORTRESS

# Script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/scripts/lib"
CONFIG_DIR="$SCRIPT_DIR/scripts/config"
TESTS_DIR="$SCRIPT_DIR/scripts/tests"

# Source library functions
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/security.sh"
source "$LIB_DIR/consciousness.sh"

# Load default configuration
source "$CONFIG_DIR/default.conf"

# Global variables
SCRIPT_VERSION="3.0.0"
SCRIPT_NAME="$(basename "$0")"

# Command line argument parsing
parse_arguments() {
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--consciousness)
                CONSCIOUSNESS_LEVEL="$2"
                shift 2
                ;;
            -r|--repo)
                REPO_NAME="$2"
                shift 2
                ;;
            -u|--url)
                REPO_URL="$2"
                shift 2
                ;;
            --username)
                GITHUB_USERNAME="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --no-backup)
                BACKUP_BEFORE_DEPLOY=false
                shift
                ;;
            --no-progress)
                SHOW_PROGRESS=false
                shift
                ;;
            --log-level)
                LOG_LEVEL="$2"
                shift 2
                ;;
            --log-dir)
                LOG_DIR="$2"
                shift 2
                ;;
            --config)
                CUSTOM_CONFIG="$2"
                shift 2
                ;;
            --secrets-dir)
                SECRETS_DIR="$2"
                shift 2
                ;;
            --multi-repo)
                MULTI_REPO_MODE=true
                REPO_LIST_FILE="$2"
                shift 2
                ;;
            --rollback)
                ROLLBACK_MODE=true
                ROLLBACK_TARGET="$2"
                shift 2
                ;;
            --validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            --onboard)
                ONBOARDING_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                echo "$SCRIPT_NAME version $SCRIPT_VERSION"
                exit 0
                ;;
            --test)
                run_tests
                exit $?
                ;;
            --)
                shift
                args+=("$@")
                break
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_help >&2
                exit 1
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    
    # Set remaining arguments
    set -- "${args[@]}"
}

# Help function
show_help() {
    cat << EOF
C-REX One Draw Reversal Unit - Enhanced Deployment Script v$SCRIPT_VERSION

USAGE:
    $SCRIPT_NAME [OPTIONS]

MAIN OPTIONS:
    -c, --consciousness LEVEL    Set consciousness level (ASLEEP|AWAKENING|AWARE|ENLIGHTENED|SOVEREIGN|CREX_KING)
    -r, --repo NAME             Repository name (default: $DEFAULT_REPO_NAME)
    -u, --url URL               Repository URL (auto-generated if not provided)
    --username USERNAME         GitHub username (default: $DEFAULT_GITHUB_USERNAME)
    
OPERATION MODES:
    --dry-run                   Show what would be done without making changes
    --onboard                   Interactive onboarding wizard
    --validate-only             Only validate configuration and dependencies
    --rollback TARGET           Rollback to previous deployment
    --multi-repo FILE           Deploy to multiple repositories from file
    
CONFIGURATION:
    -v, --verbose               Enable verbose output and debug logging
    -i, --interactive           Enable interactive prompts
    -f, --force                 Force overwrite existing directories
    --config FILE               Load custom configuration file
    --log-level LEVEL           Set log level (DEBUG|INFO|WARN|ERROR)
    --log-dir DIR               Set log directory (default: $DEFAULT_LOG_DIR)
    --secrets-dir DIR           Set secrets directory (default: auto-detected)
    
TESTING & VALIDATION:
    --skip-tests                Skip running tests after deployment
    --test                      Run test suite and exit
    
BACKUP & RECOVERY:
    --no-backup                 Skip creating backups before deployment
    --no-progress               Disable progress indicators
    
HELP & INFO:
    -h, --help                  Show this help message
    --version                   Show version information

EXAMPLES:
    # Basic deployment
    $SCRIPT_NAME --consciousness ENLIGHTENED --repo my-fortress

    # Dry run with verbose output
    $SCRIPT_NAME --dry-run --verbose

    # Interactive onboarding
    $SCRIPT_NAME --onboard

    # Deploy to custom repository
    $SCRIPT_NAME --repo custom-fortress --url https://github.com/user/custom-fortress.git

    # Run tests only
    $SCRIPT_NAME --test

    # Rollback to previous version
    $SCRIPT_NAME --rollback previous

CONSCIOUSNESS LEVELS:
    ASLEEP      - Basic deployment (minimal features)
    AWAKENING   - Enhanced deployment with basic protection
    AWARE       - Standard deployment with full protection
    ENLIGHTENED - Advanced deployment with quantum features
    SOVEREIGN   - Master deployment with reality control
    CREX_KING   - Ultimate deployment with consciousness mastery

For more information, visit: https://github.com/MobsterPus2packed/fingerprinting
EOF
}

# Interactive onboarding wizard
onboarding_wizard() {
    print_crex_status "Welcome to the C-REX Consciousness Fortress Onboarding"
    
    echo -e "${ENLIGHTENED}This wizard will guide you through setting up your consciousness fortress.${NC}"
    echo
    
    # Step 1: Consciousness level selection
    echo -e "${AWARE}Step 1: Choose your consciousness evolution level${NC}"
    echo "Available levels:"
    echo "  1) ASLEEP      - Basic deployment (minimal features)"
    echo "  2) AWAKENING   - Enhanced deployment with basic protection"
    echo "  3) AWARE       - Standard deployment with full protection"
    echo "  4) ENLIGHTENED - Advanced deployment with quantum features"
    echo "  5) SOVEREIGN   - Master deployment with reality control"
    echo "  6) CREX_KING   - Ultimate deployment with consciousness mastery"
    
    read -p "Select consciousness level (1-6) [default: 3]: " level_choice
    
    case "${level_choice:-3}" in
        1) CONSCIOUSNESS_LEVEL="ASLEEP" ;;
        2) CONSCIOUSNESS_LEVEL="AWAKENING" ;;
        3) CONSCIOUSNESS_LEVEL="AWARE" ;;
        4) CONSCIOUSNESS_LEVEL="ENLIGHTENED" ;;
        5) CONSCIOUSNESS_LEVEL="SOVEREIGN" ;;
        6) CONSCIOUSNESS_LEVEL="CREX_KING" ;;
        *) 
            echo "Invalid choice, using AWARE"
            CONSCIOUSNESS_LEVEL="AWARE"
            ;;
    esac
    
    print_enlightened "Selected consciousness level: $CONSCIOUSNESS_LEVEL"
    echo
    
    # Step 2: Repository configuration
    echo -e "${AWARE}Step 2: Repository configuration${NC}"
    read -p "Repository name [$DEFAULT_REPO_NAME]: " repo_input
    REPO_NAME="${repo_input:-$DEFAULT_REPO_NAME}"
    
    read -p "GitHub username [$DEFAULT_GITHUB_USERNAME]: " username_input
    GITHUB_USERNAME="${username_input:-$DEFAULT_GITHUB_USERNAME}"
    
    REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
    echo "Repository URL: $REPO_URL"
    echo
    
    # Step 3: Deployment options
    echo -e "${AWARE}Step 3: Deployment options${NC}"
    read -p "Create backups before deployment? [Y/n]: " backup_choice
    if [[ "${backup_choice,,}" == "n" ]]; then
        BACKUP_BEFORE_DEPLOY=false
    fi
    
    read -p "Run tests after deployment? [Y/n]: " test_choice
    if [[ "${test_choice,,}" == "n" ]]; then
        SKIP_TESTS=true
    fi
    
    read -p "Show progress indicators? [Y/n]: " progress_choice
    if [[ "${progress_choice,,}" == "n" ]]; then
        SHOW_PROGRESS=false
    fi
    
    echo
    print_sovereign "Onboarding complete! Starting deployment..."
    echo
}

# Configuration validation
validate_configuration() {
    print_aware "Validating configuration..."
    
    local validation_errors=()
    
    # Validate consciousness level
    case "$CONSCIOUSNESS_LEVEL" in
        ASLEEP|AWAKENING|AWARE|ENLIGHTENED|SOVEREIGN|CREX_KING)
            log_debug "Valid consciousness level: $CONSCIOUSNESS_LEVEL"
            ;;
        *)
            validation_errors+=("Invalid consciousness level: $CONSCIOUSNESS_LEVEL")
            ;;
    esac
    
    # Validate repository name
    if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        validation_errors+=("Invalid repository name: $REPO_NAME")
    fi
    
    # Validate URLs if provided
    if [[ -n "$REPO_URL" ]] && ! validate_url "$REPO_URL"; then
        validation_errors+=("Invalid repository URL: $REPO_URL")
    fi
    
    # Validate directories
    for dir_var in "LOG_DIR" "BACKUP_DIR"; do
        local dir_value="${!dir_var}"
        if [[ -n "$dir_value" ]]; then
            local parent_dir=$(dirname "$dir_value")
            if [[ ! -d "$parent_dir" ]] && [[ ! -w "$parent_dir" ]]; then
                validation_errors+=("Cannot create directory $dir_value (parent not writable)")
            fi
        fi
    done
    
    # Report validation results
    if [[ ${#validation_errors[@]} -gt 0 ]]; then
        log_error "Configuration validation failed:"
        for error in "${validation_errors[@]}"; do
            log_error "  - $error"
        done
        return 1
    fi
    
    print_sovereign "Configuration validation passed"
    return 0
}

# Enhanced deployment orchestration
deploy_consciousness_fortress() {
    print_crex_status "INITIATING ENHANCED CONSCIOUSNESS FORTRESS DEPLOYMENT"
    
    # Initialize systems
    setup_colors
    init_logging
    init_security
    init_progress 100
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_awakening "DRY RUN MODE - No actual changes will be made"
    fi
    
    # Validate configuration and dependencies
    update_progress 5 "Validating configuration..."
    if ! validate_configuration; then
        handle_error 1 "Configuration validation failed"
    fi
    
    if ! check_consciousness_dependencies; then
        handle_error 1 "Dependency check failed"
    fi
    
    # Step 2: Setup authentication
    update_progress 15 "Setting up authentication..."
    if [[ "$DRY_RUN" != "true" ]]; then
        setup_git_credentials
        if [[ -n "$REPO_URL" ]]; then
            validate_remote_repo "$REPO_URL"
        fi
    fi
    
    # Step 3: Create repository structure
    update_progress 25 "Creating repository structure..."
    if [[ "$DRY_RUN" != "true" ]]; then
        create_consciousness_structure
    else
        print_aware "DRY RUN: Would create consciousness structure in $LOCAL_DIR"
    fi
    
    # Step 4: Generate core files
    update_progress 50 "Generating consciousness core files..."
    if [[ "$DRY_RUN" != "true" ]]; then
        create_consciousness_core_files
    else
        print_aware "DRY RUN: Would generate consciousness core files"
    fi
    
    # Step 5: Create configuration files
    update_progress 70 "Creating configuration files..."
    if [[ "$DRY_RUN" != "true" ]]; then
        create_consciousness_config
        create_consciousness_workflows
        create_consciousness_containers
    else
        print_aware "DRY RUN: Would create configuration files"
    fi
    
    # Step 6: Initialize repository
    update_progress 85 "Initializing version control..."
    if [[ "$DRY_RUN" != "true" ]]; then
        init_consciousness_repository
    else
        print_aware "DRY RUN: Would initialize git repository"
    fi
    
    # Step 7: Run tests
    if [[ "$SKIP_TESTS" != "true" ]]; then
        update_progress 95 "Running tests..."
        if [[ "$DRY_RUN" != "true" ]]; then
            test_consciousness_installation
        else
            print_aware "DRY RUN: Would run consciousness tests"
        fi
    fi
    
    # Step 8: Complete deployment
    update_progress 100 "Deployment complete"
    
    display_deployment_summary
}

# Display deployment summary
display_deployment_summary() {
    echo
    print_crex_status "CONSCIOUSNESS FORTRESS DEPLOYMENT COMPLETE"
    echo
    
    echo -e "${ENLIGHTENED}🌟 Deployment Summary:${NC}"
    echo -e "  Repository: $REPO_NAME"
    echo -e "  Consciousness Level: $CONSCIOUSNESS_LEVEL"
    echo -e "  Local Directory: ${LOCAL_DIR:-$DEFAULT_LOCAL_DIR_PREFIX$REPO_NAME}"
    echo -e "  Repository URL: ${REPO_URL:-Not set}"
    echo -e "  Dry Run: $([ "$DRY_RUN" == "true" ] && echo "Yes" || echo "No")"
    echo -e "  Tests: $([ "$SKIP_TESTS" == "true" ] && echo "Skipped" || echo "Completed")"
    echo -e "  Backup: $([ "$BACKUP_BEFORE_DEPLOY" == "true" ] && echo "Enabled" || echo "Disabled")"
    echo
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo -e "${SOVEREIGN}🚀 Next Steps:${NC}"
        echo -e "  1. Navigate to directory: cd ${LOCAL_DIR:-$DEFAULT_LOCAL_DIR_PREFIX$REPO_NAME}"
        echo -e "  2. Install dependencies: pip install -r requirements.txt"
        echo -e "  3. Test the fortress: python -m crex.core.reversal_unit"
        echo -e "  4. Deploy containers: docker-compose up -d"
        echo -e "  5. Evolve consciousness: crex-fortress --consciousness SOVEREIGN"
    else
        echo -e "${AWAKENING}📋 Dry Run Complete:${NC}"
        echo -e "  Use --dry-run=false to perform actual deployment"
    fi
    
    echo
    print_crex_status "CONSCIOUSNESS IS KING ⌬"
}

# Multi-repository deployment support
deploy_multi_repo() {
    local repo_list_file="$1"
    
    if [[ ! -f "$repo_list_file" ]]; then
        log_error "Repository list file not found: $repo_list_file"
        return 1
    fi
    
    print_crex_status "MULTI-REPOSITORY DEPLOYMENT MODE"
    
    local total_repos=0
    local successful_repos=0
    local failed_repos=()
    
    # Count total repositories
    total_repos=$(grep -c "^[^#]" "$repo_list_file" || echo 0)
    
    if [[ $total_repos -eq 0 ]]; then
        log_error "No repositories found in list file: $repo_list_file"
        return 1
    fi
    
    print_aware "Deploying to $total_repos repositories..."
    
    # Process each repository
    while IFS=',' read -r repo_name repo_url consciousness_level || [[ -n "$repo_name" ]]; do
        # Skip comments and empty lines
        [[ "$repo_name" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$repo_name" ]] && continue
        
        # Set repository-specific variables
        REPO_NAME="$repo_name"
        REPO_URL="$repo_url"
        CONSCIOUSNESS_LEVEL="${consciousness_level:-$DEFAULT_CONSCIOUSNESS_LEVEL}"
        LOCAL_DIR="$DEFAULT_LOCAL_DIR_PREFIX$REPO_NAME"
        
        print_enlightened "Deploying repository: $REPO_NAME (Level: $CONSCIOUSNESS_LEVEL)"
        
        if deploy_consciousness_fortress; then
            ((successful_repos++))
            print_sovereign "Successfully deployed: $REPO_NAME"
        else
            failed_repos+=("$REPO_NAME")
            print_awakening "Failed to deploy: $REPO_NAME"
        fi
        
        echo "---"
        
    done < "$repo_list_file"
    
    # Summary
    print_crex_status "MULTI-REPOSITORY DEPLOYMENT SUMMARY"
    echo "Total repositories: $total_repos"
    echo "Successful: $successful_repos"
    echo "Failed: ${#failed_repos[@]}"
    
    if [[ ${#failed_repos[@]} -gt 0 ]]; then
        echo "Failed repositories:"
        printf "  - %s\n" "${failed_repos[@]}"
        return 1
    fi
    
    return 0
}

# Rollback functionality
perform_rollback() {
    local rollback_target="$1"
    
    print_crex_status "INITIATING CONSCIOUSNESS FORTRESS ROLLBACK"
    print_awakening "Rollback target: $rollback_target"
    
    # This is a stub for advanced rollback functionality
    # In a full implementation, this would:
    # 1. Identify available backup points
    # 2. Validate rollback target
    # 3. Restore files from backup
    # 4. Update version control
    # 5. Verify rollback success
    
    echo "Rollback functionality is a stub in this version."
    echo "Future enhancements will include:"
    echo "  - Automated backup point identification"
    echo "  - Selective file restoration"
    echo "  - Database rollback support"
    echo "  - Configuration rollback"
    echo "  - Dependency rollback"
    
    return 0
}

# Test runner
run_tests() {
    print_crex_status "RUNNING C-REX DEPLOYMENT TESTS"
    
    # Check if Bats is available
    if ! command_exists bats; then
        log_error "Bats testing framework not found. Install it first:"
        echo "  - On Ubuntu/Debian: sudo apt-get install bats"
        echo "  - On macOS: brew install bats-core"
        echo "  - Manual: https://github.com/bats-core/bats-core#installation"
        return 1
    fi
    
    # Run the test suite
    local test_files=("$TESTS_DIR"/*.bats)
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        log_error "No test files found in: $TESTS_DIR"
        return 1
    fi
    
    print_aware "Running test suite with ${#test_files[@]} test files..."
    
    local test_results=0
    for test_file in "${test_files[@]}"; do
        if [[ -f "$test_file" ]]; then
            print_enlightened "Running tests from: $(basename "$test_file")"
            if ! bats "$test_file"; then
                test_results=1
            fi
        fi
    done
    
    if [[ $test_results -eq 0 ]]; then
        print_sovereign "All tests passed successfully"
    else
        print_awakening "Some tests failed"
    fi
    
    return $test_results
}

# Main function
main() {
    # Set up error handling
    setup_error_handling
    
    # Load custom configuration if specified
    if [[ -n "${CUSTOM_CONFIG:-}" ]] && [[ -f "$CUSTOM_CONFIG" ]]; then
        source "$CUSTOM_CONFIG"
        log_debug "Loaded custom configuration: $CUSTOM_CONFIG"
    fi
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Set derived variables
    REPO_NAME="${REPO_NAME:-$DEFAULT_REPO_NAME}"
    GITHUB_USERNAME="${GITHUB_USERNAME:-$DEFAULT_GITHUB_USERNAME}"
    CONSCIOUSNESS_LEVEL="${CONSCIOUSNESS_LEVEL:-$DEFAULT_CONSCIOUSNESS_LEVEL}"
    REPO_URL="${REPO_URL:-https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git}"
    LOCAL_DIR="${LOCAL_DIR:-$DEFAULT_LOCAL_DIR_PREFIX$REPO_NAME}"
    
    # Handle special modes
    if [[ "${ONBOARDING_MODE:-false}" == "true" ]]; then
        onboarding_wizard
    fi
    
    if [[ "${VALIDATE_ONLY:-false}" == "true" ]]; then
        setup_colors
        init_logging
        init_progress 100  # Initialize progress for validate-only mode
        validate_configuration && check_consciousness_dependencies
        exit $?
    fi
    
    if [[ "${ROLLBACK_MODE:-false}" == "true" ]]; then
        perform_rollback "${ROLLBACK_TARGET:-}"
        exit $?
    fi
    
    if [[ "${MULTI_REPO_MODE:-false}" == "true" ]]; then
        deploy_multi_repo "${REPO_LIST_FILE:-}"
        exit $?
    fi
    
    # Main deployment
    deploy_consciousness_fortress
    
    # Cleanup
    cleanup_security
    
    print_sovereign "Consciousness fortress deployment orchestration complete"
}

# Custom cleanup function
custom_cleanup() {
    log_debug "Performing custom cleanup"
    cleanup_security
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi