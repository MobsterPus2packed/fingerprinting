#!/bin/bash

# C-REX Consciousness Fortress - Rollback Script
# Safely undo deployment changes if needed

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DRY_RUN=false
VERBOSE=false
FORCE=false

# Show help
show_help() {
    cat << 'EOF'
⌬ C-REX Consciousness Fortress - Rollback Script ⌁

USAGE:
    ./rollback.sh [OPTIONS] [TARGET_DIRECTORY]

OPTIONS:
    -d, --dry-run              Show what would be done without executing
    -v, --verbose              Enable verbose output
    -f, --force                Force rollback without confirmation
    -h, --help                 Show this help message

ARGUMENTS:
    TARGET_DIRECTORY           Directory containing the consciousness fortress to rollback
                              Default: auto-detect based on common patterns

EXAMPLES:
    # Rollback with confirmation
    ./rollback.sh ./crex-one-draw-reversal-unit

    # Dry run to see what would be removed
    ./rollback.sh --dry-run ./my-fortress

    # Force rollback without confirmation
    ./rollback.sh --force ./test-fortress

⌬ CONSCIOUSNESS ROLLBACK PROTOCOL ⌁
EOF
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run|-d)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                TARGET_DIR="$1"
                shift
                ;;
        esac
    done
}

# Logging functions
log_info() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[INFO] $1${NC}" >&2
    fi
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}" >&2
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}" >&2
}

# Execute command with dry-run support
execute_command() {
    local cmd="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN] Would execute: $description${NC}"
        echo -e "${BLUE}Command: $cmd${NC}"
    else
        log_info "Executing: $description"
        eval "$cmd"
    fi
}

# Auto-detect fortress directories
auto_detect_fortress() {
    local candidates=(
        "./crex-one-draw-reversal-unit"
        "./test-fortress"
        "./my-fortress"
        "./*-fortress"
        "./crex-*"
    )
    
    for pattern in "${candidates[@]}"; do
        for dir in $pattern; do
            if [[ -d "$dir" ]] && [[ -f "$dir/setup.py" || -f "$dir/requirements.txt" ]]; then
                echo "$dir"
                return 0
            fi
        done
    done
    
    return 1
}

# Validate fortress directory
validate_fortress() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        log_error "Directory does not exist: $dir"
        return 1
    fi
    
    # Check for consciousness fortress markers
    local markers=(
        "setup.py"
        "requirements.txt"
        "src/crex"
        ".git"
        "README.md"
    )
    
    local found_markers=0
    for marker in "${markers[@]}"; do
        if [[ -e "$dir/$marker" ]]; then
            found_markers=$((found_markers + 1))
            log_info "Found consciousness marker: $marker"
        fi
    done
    
    if [[ $found_markers -lt 2 ]]; then
        log_warning "Directory doesn't appear to be a consciousness fortress: $dir"
        log_warning "Found only $found_markers consciousness markers"
        return 1
    fi
    
    log_success "Validated consciousness fortress: $dir"
    return 0
}

# Rollback fortress
rollback_fortress() {
    local dir="$1"
    
    echo -e "${RED}⚠️  CONSCIOUSNESS FORTRESS ROLLBACK INITIATED ⚠️${NC}"
    echo -e "${YELLOW}Target: $dir${NC}"
    echo ""
    
    if [[ "$FORCE" != "true" ]] && [[ "$DRY_RUN" != "true" ]]; then
        echo -e "${YELLOW}This will permanently remove the consciousness fortress and all its contents.${NC}"
        echo -e "${YELLOW}Are you sure you want to proceed? (type 'YES' to confirm):${NC}"
        read -r confirmation
        
        if [[ "$confirmation" != "YES" ]]; then
            log_info "Rollback cancelled by user"
            exit 0
        fi
    fi
    
    echo -e "${RED}🔥 BEGINNING CONSCIOUSNESS FORTRESS ROLLBACK 🔥${NC}"
    echo ""
    
    # Remove the fortress directory
    execute_command "rm -rf '$dir'" "Removing consciousness fortress directory: $dir"
    
    # Clean up any related files in parent directory
    local parent_dir
    parent_dir=$(dirname "$dir")
    
    if [[ -f "$parent_dir/deploy_crex_fortress.sh" ]]; then
        execute_command "rm -f '$parent_dir/deploy_crex_fortress.sh'" "Removing deployment script backup"
    fi
    
    # Remove any temporary directories
    local temp_patterns=(
        "/tmp/crex-*"
        "/tmp/*-fortress"
        "/tmp/consciousness-*"
    )
    
    for pattern in "${temp_patterns[@]}"; do
        for temp_dir in $pattern; do
            if [[ -d "$temp_dir" ]]; then
                execute_command "rm -rf '$temp_dir'" "Removing temporary directory: $temp_dir"
            fi
        done
    done
    
    if [[ "$DRY_RUN" != "true" ]]; then
        log_success "Consciousness fortress rollback completed"
        echo ""
        echo -e "${GREEN}⌬ CONSCIOUSNESS FORTRESS SUCCESSFULLY ROLLED BACK ⌁${NC}"
        echo -e "${BLUE}The consciousness fortress has been removed from reality${NC}"
        echo -e "${BLUE}All traces have been eliminated from the local system${NC}"
    else
        echo ""
        echo -e "${YELLOW}[DRY-RUN] Rollback simulation completed${NC}"
        echo -e "${BLUE}Run without --dry-run to execute the rollback${NC}"
    fi
}

# Main function
main() {
    parse_arguments "$@"
    
    echo -e "${BLUE}⌬ C-REX Consciousness Fortress - Rollback Protocol ⌁${NC}"
    echo ""
    
    # Determine target directory
    if [[ -z "$TARGET_DIR" ]]; then
        log_info "Auto-detecting consciousness fortress..."
        
        if TARGET_DIR=$(auto_detect_fortress); then
            log_info "Auto-detected fortress: $TARGET_DIR"
        else
            log_error "No consciousness fortress detected automatically"
            log_error "Please specify the fortress directory manually"
            show_help
            exit 1
        fi
    fi
    
    # Validate the fortress
    if ! validate_fortress "$TARGET_DIR"; then
        if [[ "$FORCE" == "true" ]]; then
            log_warning "Validation failed but proceeding due to --force flag"
        else
            log_error "Fortress validation failed. Use --force to override"
            exit 1
        fi
    fi
    
    # Perform rollback
    rollback_fortress "$TARGET_DIR"
}

# Execute main function
main "$@"