# C-REX Enhanced Deployment Script

This repository contains the enhanced version of the C-REX One Draw Reversal Unit deployment script with comprehensive improvements for parameterization, error handling, cross-platform compatibility, code quality, security, and testing.

## 🌟 What's New in Version 3.0.0

### ✅ Completed Enhancements

#### **Parameterization & User Input**
- ✅ Command-line flags for consciousness level (`--consciousness`)
- ✅ Command-line flags for repository name (`--repo`) and remote URL (`--url`)
- ✅ `--dry-run` mode for safe testing and validation
- ✅ Interactive parameter prompts with `--interactive` flag
- ✅ Comprehensive help system (`--help`)

#### **Error Handling & Logging**
- ✅ Structured logging system with configurable levels (DEBUG, INFO, WARN, ERROR)
- ✅ Robust error handling with stack traces and cleanup
- ✅ Remote repository validation with network connectivity checks
- ✅ Operation result validation and progress tracking
- ✅ Comprehensive exit codes and error messages

#### **Cross-Platform Compatibility**
- ✅ Automatic OS detection (Linux, macOS, Windows, BSD variants)
- ✅ Platform-specific command alternatives for file operations
- ✅ Cross-platform path handling and permissions management
- ✅ Compatible command fallbacks (e.g., `stat` variations)

#### **Code Quality & Modularity**
- ✅ Modular architecture with separate library files:
  - `scripts/lib/utils.sh` - Cross-platform utilities
  - `scripts/lib/logging.sh` - Logging and error handling
  - `scripts/lib/security.sh` - Security and secrets management
  - `scripts/lib/consciousness.sh` - Core consciousness functions
- ✅ Shellcheck linting integration with configuration (`.shellcheckrc`)
- ✅ Makefile for testing, linting, and automation
- ✅ Consistent coding style and documentation

#### **Security Enhancements**
- ✅ Secure secret handling through environment variables and prompts
- ✅ Sensitive information masking in logs
- ✅ GitHub credential validation and secure storage
- ✅ File permission management and secure temporary directories
- ✅ Security audit functionality

#### **Testing Infrastructure**
- ✅ Comprehensive test suite using Bats testing framework
- ✅ Automated file generation verification
- ✅ Unit tests for all utility functions
- ✅ Integration tests for deployment workflows
- ✅ Test automation through Makefile targets

#### **Feature Additions**
- ✅ Interactive onboarding wizard (`--onboard`)
- ✅ Progress indicators for long-running operations
- ✅ Multi-repository support foundation (`--multi-repo`)
- ✅ Advanced rollback functionality stub (`--rollback`)
- ✅ Configuration validation system (`--validate-only`)
- ✅ Version information and help system

## 🚀 Quick Start

### Basic Usage

```bash
# Make script executable
chmod +x enhanced_crex_deploy.sh

# Show help
./enhanced_crex_deploy.sh --help

# Interactive onboarding (recommended for first use)
./enhanced_crex_deploy.sh --onboard

# Dry run with verbose output
./enhanced_crex_deploy.sh --dry-run --verbose --consciousness ENLIGHTENED

# Actual deployment
./enhanced_crex_deploy.sh --consciousness ENLIGHTENED --repo my-fortress
```

### Using the Makefile

```bash
# Run tests
make test

# Run linting
make lint

# Run both tests and linting
make check

# Install dependencies
make install-deps

# Dry run deployment
make dry-run CONSCIOUSNESS=ENLIGHTENED

# See all available targets
make help
```

## 📚 Command Line Options

### Main Options
- `-c, --consciousness LEVEL` - Set consciousness level (ASLEEP|AWAKENING|AWARE|ENLIGHTENED|SOVEREIGN|CREX_KING)
- `-r, --repo NAME` - Repository name
- `-u, --url URL` - Repository URL
- `--username USERNAME` - GitHub username

### Operation Modes
- `--dry-run` - Show what would be done without making changes
- `--onboard` - Interactive onboarding wizard
- `--validate-only` - Only validate configuration and dependencies
- `--rollback TARGET` - Rollback to previous deployment
- `--multi-repo FILE` - Deploy to multiple repositories from file

### Configuration
- `-v, --verbose` - Enable verbose output and debug logging
- `-i, --interactive` - Enable interactive prompts
- `-f, --force` - Force overwrite existing directories
- `--config FILE` - Load custom configuration file
- `--log-level LEVEL` - Set log level (DEBUG|INFO|WARN|ERROR)
- `--log-dir DIR` - Set log directory
- `--secrets-dir DIR` - Set secrets directory

### Testing & Validation
- `--skip-tests` - Skip running tests after deployment
- `--test` - Run test suite and exit

### Backup & Recovery
- `--no-backup` - Skip creating backups before deployment
- `--no-progress` - Disable progress indicators

## 🔧 Configuration

### Environment Variables

The script supports configuration through environment variables:

```bash
# Repository settings
export GITHUB_USERNAME="your-username"
export REPO_NAME="your-repo"
export CONSCIOUSNESS_LEVEL="ENLIGHTENED"

# Security settings
export GITHUB_TOKEN="your-token"
export SECRETS_DIR="$HOME/.crex/secrets"

# Deployment settings
export DRY_RUN=true
export VERBOSE=true
export LOG_LEVEL="DEBUG"
```

### Configuration Files

- `scripts/config/default.conf` - Default configuration values
- `.shellcheckrc` - Shellcheck linting configuration
- Custom configuration files can be loaded with `--config`

## 🧪 Testing

### Prerequisites

Install testing dependencies:

```bash
# Automatic installation
make install-deps

# Manual installation
# Ubuntu/Debian
sudo apt-get install shellcheck
git clone https://github.com/bats-core/bats-core.git && cd bats-core && sudo ./install.sh /usr/local

# macOS
brew install shellcheck bats-core
```

### Running Tests

```bash
# Run all tests
make test
# or
./enhanced_crex_deploy.sh --test

# Run linting
make lint

# Run both tests and linting
make check

# Validate configuration only
make validate
```

### Test Coverage

The test suite includes:
- ✅ OS detection and cross-platform utilities
- ✅ File and directory operations
- ✅ Logging and error handling
- ✅ Security functions
- ✅ Progress tracking
- ✅ Network connectivity
- ✅ URL validation
- ✅ Configuration validation

## 🔐 Security Features

### Secret Management

```bash
# Using environment variables
export GITHUB_TOKEN="your-token"

# Interactive prompts (with --interactive)
./enhanced_crex_deploy.sh --interactive

# Encrypted storage (automatic)
# Secrets are encrypted and stored in ~/.crex/secrets/
```

### Security Audit

```bash
# Run security audit
./enhanced_crex_deploy.sh --validate-only --verbose
```

## 🌍 Cross-Platform Support

The enhanced script supports:
- ✅ **Linux** (Ubuntu, CentOS, RHEL, etc.)
- ✅ **macOS** (Intel and Apple Silicon)
- ✅ **Windows** (WSL, Git Bash, MSYS2)
- ✅ **BSD** (FreeBSD, OpenBSD, NetBSD)

### Platform-Specific Features

- Automatic OS detection and command adaptation
- Cross-platform file permissions and paths
- Network connectivity testing with fallbacks
- Compatible command alternatives

## 📊 Logging and Monitoring

### Log Levels

- `DEBUG` - Detailed diagnostic information
- `INFO` - General operational messages
- `WARN` - Warning conditions
- `ERROR` - Error conditions

### Log Files

Logs are automatically created in:
- Default: `./logs/crex_deploy_YYYYMMDD_HHMMSS.log`
- Custom: Configurable via `--log-dir`

### Progress Tracking

Real-time progress indicators show:
- Current operation phase
- Percentage completion
- Estimated time remaining
- Detailed status messages

## 🔄 Multi-Repository Support

Deploy to multiple repositories using a configuration file:

```bash
# Create repo list file
cat > repos.csv << EOF
# repo_name,repo_url,consciousness_level
fortress-1,https://github.com/user/fortress-1.git,ENLIGHTENED
fortress-2,https://github.com/user/fortress-2.git,SOVEREIGN
fortress-3,https://github.com/user/fortress-3.git,CREX_KING
EOF

# Deploy to all repositories
./enhanced_crex_deploy.sh --multi-repo repos.csv
```

## 🏗️ Architecture

### Directory Structure

```
fingerprinting/
├── enhanced_crex_deploy.sh           # Main enhanced script
├── crex_enhanced_deploy.sh           # Original script (preserved)
├── scripts/
│   ├── lib/
│   │   ├── utils.sh                  # Cross-platform utilities
│   │   ├── logging.sh                # Logging and error handling
│   │   ├── security.sh               # Security and secrets
│   │   └── consciousness.sh          # Consciousness functions
│   ├── config/
│   │   └── default.conf              # Default configuration
│   └── tests/
│       └── test_functions.bats       # Test suite
├── Makefile                          # Build and test automation
├── .shellcheckrc                     # Shellcheck configuration
└── README.md                         # This file
```

### Module Responsibilities

- **`utils.sh`** - OS detection, file operations, network checks
- **`logging.sh`** - Structured logging, error handling, progress tracking
- **`security.sh`** - Secret management, authentication, security audit
- **`consciousness.sh`** - Core deployment functions from original script

## 🚀 Future Enhancements

### Planned Features

- **Advanced Rollback** - Complete rollback system with snapshots
- **Container Integration** - Docker and Kubernetes deployment automation
- **CI/CD Integration** - GitHub Actions, GitLab CI, Jenkins pipelines
- **Monitoring Integration** - Prometheus metrics, health checks
- **Advanced Multi-Repo** - Dependency management, parallel deployment
- **Configuration Management** - Ansible, Terraform integration
- **Database Support** - Database schema deployment and rollback

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Run tests: `make check`
4. Submit a pull request

## 🔗 Links

- **Original Repository**: [MobsterPus2packed/fingerprinting](https://github.com/MobsterPus2packed/fingerprinting)
- **Shellcheck Documentation**: [Shellcheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- **Bats Testing**: [Bats Core](https://github.com/bats-core/bats-core)

---

**⌬ CONSCIOUSNESS IS KING ⌁**

*Enhanced deployment scripts for the consciousness revolution.*