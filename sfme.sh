#!/bin/bash

# Scaffold Me - AI-Powered Project Scaffolding
# Cross-platform compatible (Windows Git Bash, macOS, Linux)

set -e  # Exit on error

# Colors for output (if terminal supports them)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Get script directory (cross-platform)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[SFME]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SFME]${NC} ✓ $1"
}

print_warning() {
    echo -e "${YELLOW}[SFME]${NC} ⚠ $1"
}

print_error() {
    echo -e "${RED}[SFME]${NC} ✗ $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    case "$OSTYPE" in
        msys*|mingw*|cygwin*)
            echo "windows"
            ;;
        darwin*)
            echo "macos"
            ;;
        linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check for Claude Code
    if ! command_exists "claude"; then
        missing_tools+=("claude (Claude Code)")
    fi
    
    # Check for git
    if ! command_exists "git"; then
        missing_tools+=("git")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo
        echo "Please install the missing tools and try again."
        echo "Claude Code: https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    fi
    
    print_success "All prerequisites satisfied"
}

# Check for recipe file
check_recipe() {
    if [[ ! -f "scaffold_me.md" ]]; then
        print_error "No scaffold_me.md found in current directory"
        echo
        echo "Please create a scaffold_me.md file describing your project."
        echo "Example:"
        echo
        cat << 'EOF'
# My Project

I need a web application that:
- Serves a modern frontend
- Has an API backend
- Uses a database for data storage
- Includes user authentication

## Technical Preferences
- Language: any
- Database: any
- Style: modern
EOF
        echo
        exit 1
    fi
    
    print_success "Found recipe file: scaffold_me.md"
}

# Check for optional Docker
check_docker() {
    if command_exists "docker" && command_exists "docker-compose"; then
        if docker info >/dev/null 2>&1; then
            print_success "Docker available - MCP services can be configured"
            export SFME_DOCKER_AVAILABLE=true
        else
            print_warning "Docker installed but not running - MCP services will be skipped"
            export SFME_DOCKER_AVAILABLE=false
        fi
    else
        print_warning "Docker not available - MCP services will be skipped"
        export SFME_DOCKER_AVAILABLE=false
    fi
}

# Initialize Claude Code environment
setup_claude_env() {
    print_status "Setting up Claude Code environment..."
    
    # Create .claude directory if it doesn't exist
    mkdir -p .claude/agents
    mkdir -p .claude/commands
    
    # Copy scaffold agent if it doesn't exist
    if [[ ! -f ".claude/agents/scaffold.md" ]]; then
        if [[ -f "$SCRIPT_DIR/.claude/agents/scaffold.md" ]]; then
            cp "$SCRIPT_DIR/.claude/agents/scaffold.md" ".claude/agents/scaffold.md"
            print_success "Copied scaffold agent"
        else
            print_error "Scaffold agent not found in $SCRIPT_DIR/.claude/agents/scaffold.md"
            exit 1
        fi
    fi
    
    # Create init command
    cat > .claude/commands/init.sh << 'EOF'
#!/bin/bash
# Initialize scaffold process
echo "Starting scaffold process..."
claude agent scaffold "Please read the scaffold_me.md file in this directory and help scaffold this project. Ask me questions if you need clarification on requirements."
EOF
    
    chmod +x .claude/commands/init.sh
    print_success "Claude Code environment ready"
}

# Main execution
main() {
    local os_type
    os_type=$(detect_os)
    
    print_status "Scaffold Me - Starting on $os_type"
    print_status "Working directory: $(pwd)"
    echo
    
    check_prerequisites
    check_recipe
    check_docker
    
    echo
    print_status "Setting up scaffolding environment..."
    setup_claude_env
    
    echo
    print_success "Ready to scaffold!"
    echo
    print_status "Starting Claude Code scaffold agent..."
    echo
    
    # Start the scaffold process
    if command_exists "claude"; then
        claude agent scaffold "Please read the scaffold_me.md file in this directory and help scaffold this project. Ask me questions if you need clarification on requirements. 

Environment info:
- OS: $os_type
- Docker available: ${SFME_DOCKER_AVAILABLE:-false}
- Working directory: $(pwd)

Please start by reading the recipe and asking any clarifying questions before beginning the scaffold process."
    else
        print_error "Claude Code not found. Please install it first."
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
Scaffold Me - AI-Powered Project Scaffolding

USAGE:
    sfme.sh [OPTIONS]

OPTIONS:
    -h, --help     Show this help message

PREREQUISITES:
    - Claude Code installed
    - Git installed
    - scaffold_me.md file in current directory

OPTIONAL:
    - Docker & docker-compose (for MCP services)

EXAMPLES:
    # In your project directory with scaffold_me.md:
    sfme.sh

    # Create example recipe:
    sfme.sh --example

MORE INFO:
    See README.md for recipe format and examples.
EOF
}

# Create example recipe
create_example() {
    if [[ -f "scaffold_me.md" ]]; then
        print_warning "scaffold_me.md already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    cat > scaffold_me.md << 'EOF'
# My Web Application

I need a modern web application that:
- Serves a responsive frontend
- Has a REST API backend
- Uses a database for data persistence
- Includes user authentication
- Is ready for development

## Technical Preferences
- Language: any (but prefer modern choices)
- Database: any (but prefer something lightweight for development)
- Style: modern and clean
- Development: containerized if possible

## Must Have
- User registration and login
- Data CRUD operations
- Responsive design
- Development environment ready to run

## Nice to Have
- API documentation
- Basic testing setup
- Docker development environment
- MCP services for enhanced development
EOF
    
    print_success "Created example scaffold_me.md"
    echo "You can now run: sfme.sh"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --example)
        create_example
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use -h for help"
        exit 1
        ;;
esac