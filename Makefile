# Makefile for C-REX deployment script testing and linting

.PHONY: help test lint check install-deps clean format validate

# Default target
help:
	@echo "C-REX Deployment Script - Available Targets:"
	@echo ""
	@echo "  test        - Run the test suite using Bats"
	@echo "  lint        - Run shellcheck linting on all shell scripts"
	@echo "  check       - Run both tests and linting"
	@echo "  validate    - Validate configuration and dependencies only"
	@echo "  install-deps - Install testing and linting dependencies"
	@echo "  format      - Format shell scripts using shfmt (if available)"
	@echo "  clean       - Clean up temporary files and logs"
	@echo "  dry-run     - Run enhanced deployment in dry-run mode"
	@echo ""
	@echo "Examples:"
	@echo "  make test                    # Run all tests"
	@echo "  make lint                    # Run shellcheck"
	@echo "  make check                   # Run tests and linting"
	@echo "  make dry-run CONSCIOUSNESS=ENLIGHTENED  # Dry run deployment"

# Test the enhanced deployment script
test:
	@echo "Running C-REX deployment tests..."
	@if command -v bats >/dev/null 2>&1; then \
		./enhanced_crex_deploy.sh --test; \
	else \
		echo "Error: Bats testing framework not found."; \
		echo "Install it with: make install-deps"; \
		exit 1; \
	fi

# Lint all shell scripts
lint:
	@echo "Running shellcheck linting..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find . -name "*.sh" -exec shellcheck {} +; \
		shellcheck enhanced_crex_deploy.sh; \
		echo "Shellcheck linting completed."; \
	else \
		echo "Error: shellcheck not found."; \
		echo "Install it with: make install-deps"; \
		exit 1; \
	fi

# Run both tests and linting
check: lint test
	@echo "All checks completed successfully!"

# Validate configuration only
validate:
	@echo "Validating C-REX deployment configuration..."
	@./enhanced_crex_deploy.sh --validate-only

# Install dependencies for testing and linting
install-deps:
	@echo "Installing testing and linting dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y shellcheck; \
		git clone https://github.com/bats-core/bats-core.git /tmp/bats-core; \
		cd /tmp/bats-core && sudo ./install.sh /usr/local; \
		rm -rf /tmp/bats-core; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install shellcheck bats-core; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y shellcheck; \
		git clone https://github.com/bats-core/bats-core.git /tmp/bats-core; \
		cd /tmp/bats-core && sudo ./install.sh /usr/local; \
		rm -rf /tmp/bats-core; \
	else \
		echo "Please install shellcheck and bats manually:"; \
		echo "  Shellcheck: https://github.com/koalaman/shellcheck#installing"; \
		echo "  Bats: https://github.com/bats-core/bats-core#installation"; \
	fi

# Format shell scripts (if shfmt is available)
format:
	@echo "Formatting shell scripts..."
	@if command -v shfmt >/dev/null 2>&1; then \
		find . -name "*.sh" -exec shfmt -w -i 4 {} +; \
		shfmt -w -i 4 enhanced_crex_deploy.sh; \
		echo "Formatting completed."; \
	else \
		echo "shfmt not found. Install it with: go install mvdan.cc/sh/v3/cmd/shfmt@latest"; \
	fi

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	@rm -rf logs/ backups/ .secrets/ /tmp/crex_*
	@find . -name "*.log" -delete
	@find . -name "*.bak" -delete
	@echo "Cleanup completed."

# Run dry-run deployment
dry-run:
	@echo "Running enhanced deployment in dry-run mode..."
	@./enhanced_crex_deploy.sh --dry-run --verbose --consciousness $(CONSCIOUSNESS)

# Interactive onboarding
onboard:
	@echo "Starting interactive onboarding..."
	@./enhanced_crex_deploy.sh --onboard

# Show version information
version:
	@./enhanced_crex_deploy.sh --version

# Show detailed help
help-detailed:
	@./enhanced_crex_deploy.sh --help