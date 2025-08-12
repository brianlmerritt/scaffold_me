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
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
fi

# Get script directory (cross-platform) - resolve symlinks
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}")")" && pwd)"

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

print_header() {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Claude Code authentication
check_claude_auth() {
    if ! command_exists "claude"; then
        return 1
    fi
    
    # Try to run a simple claude command that requires auth
    # The 'claude status' or similar command would be ideal, but let's try a safe approach
    local auth_check
    auth_check=$(claude --help 2>/dev/null | grep -i "login\|auth\|subscription" || echo "")
    
    # Try to check if we can access Claude's features
    # This is a heuristic approach since Claude Code's auth check methods may vary
    if claude agent --help >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
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
    local warnings=()
    
    # Check for Claude Code
    if ! command_exists "claude"; then
        missing_tools+=("claude (Claude Code)")
    else
        # Claude Code is installed, check if it's authenticated
        print_status "Checking Claude Code authentication..."
        if ! check_claude_auth; then
            print_error "Claude Code is installed but not authenticated"
            echo
            echo "Please log into Claude Code first:"
            if is_remote_session; then
                echo "  1. On your local machine, run: claude login"
                echo "  2. Complete the browser authentication"
                echo "  3. If using remote development, ensure Claude Code is authenticated on the remote system"
                echo
                echo "For remote development, you may need to:"
                echo "  - Copy authentication tokens to the remote system"
                echo "  - Or run Claude Code from your local machine pointing to the remote directory"
            else
                echo "  Run: claude login"
                echo "  Then complete the browser authentication"
            fi
            echo
            echo "After authentication, run this script again."
            exit 1
        else
            print_success "Claude Code authenticated and ready"
        fi
    fi
    
    # Check for git
    if ! command_exists "git"; then
        missing_tools+=("git")
    fi
    
    # Check for at least one IDE (not required but recommended)
    if ! command_exists "code" && ! command_exists "cursor"; then
        warnings+=("No IDE detected (VSCode or Cursor recommended)")
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
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        for warning in "${warnings[@]}"; do
            print_warning "$warning"
        done
    fi
    
    print_success "All prerequisites satisfied"
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

# Scan for available recipes
scan_recipes() {
    local recipes_dir="$SCRIPT_DIR/recipes"
    local recipes=()
    
    if [[ -d "$recipes_dir" ]]; then
        # Only find .md files and extract basename without .md extension
        while IFS= read -r -d '' file; do
            local basename=$(basename "$file" .md)
            recipes+=("$basename")
        done < <(find "$recipes_dir" -name "*.md" -type f -print0 2>/dev/null | sort -z)
    fi
    
    printf '%s\n' "${recipes[@]}"
}

# Replace the display_recipes function (around lines 149-185)
display_recipes() {
    local -a recipes=("$@")
    local total=${#recipes[@]}
    local page=${RECIPE_PAGE:-0}
    local per_page=5
    local start=$((page * per_page))
    local end=$((start + per_page))
    
    echo
    print_header "Available Options:"
    echo
    
    if [[ $total -eq 0 ]]; then
        echo "  No recipes found in $SCRIPT_DIR/recipes/"
        echo "  (Only .md files are recognized as recipes)"
        
        # Show what files exist but aren't .md
        local recipes_dir="$SCRIPT_DIR/recipes"
        if [[ -d "$recipes_dir" ]]; then
            local other_files
            other_files=$(find "$recipes_dir" -type f ! -name "*.md" 2>/dev/null | wc -l)
            if [[ $other_files -gt 0 ]]; then
                echo "  Found $other_files non-.md files:"
                find "$recipes_dir" -type f ! -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/    /'
            fi
        fi
        echo
    else
        echo "Available Recipes:"
        echo
        
        local option=1
        for ((i=start; i<end && i<total; i++)); do
            local recipe=${recipes[i]}
            local recipe_file="$SCRIPT_DIR/recipes/${recipe}.md"
            local description=""
            
            # Try to extract description from recipe file
            if [[ -f "$recipe_file" ]]; then
                description=$(grep -m1 "^I need\|^A \|^.*that" "$recipe_file" 2>/dev/null | head -1 | sed 's/^[^a-zA-Z]*//' || echo "")
            fi
            
            printf "  %d. %-20s" $option "$recipe"
            if [[ -n "$description" ]]; then
                echo " - $description"
            else
                echo
            fi
            ((option++))
        done
        echo
        
        # Show pagination options if needed
        local recipe_count=$((option - 1))
        
        if [[ $end -lt $total ]]; then
            echo "  $option. [Show more recipes...]"
            ((option++))
        fi
        
        if [[ $page -gt 0 ]]; then
            echo "  $option. [Show previous recipes...]"
            ((option++))
        fi
        
        # Always show these options
        echo "  $option. Describe your project (type directly)"
        ((option++))
        echo "  $option. Create a template scaffold_me.md file"
    fi
}
# Get user recipe selection
get_recipe_selection() {
    local -a recipes=("$@")
    local total=${#recipes[@]}
    local page=${RECIPE_PAGE:-0}
    local per_page=5
    local start=$((page * per_page))
    local end=$((start + per_page))
    
    # Always display the menu first
    display_recipes "${recipes[@]}"
    
    # Calculate total options displayed
    local recipe_count=0
    local option_num=1
    
    # Count recipes that will be shown
    for ((i=start; i<end && i<total; i++)); do
        recipe_count=$((recipe_count + 1))
        option_num=$((option_num + 1))
    done
    
    # Count pagination options
    local show_more=false
    local show_previous=false
    local pagination_options=0
    
    if [[ $end -lt $total ]]; then
        show_more=true
        pagination_options=$((pagination_options + 1))
        option_num=$((option_num + 1))
    fi
    
    if [[ $page -gt 0 ]]; then
        show_previous=true
        pagination_options=$((pagination_options + 1))
        option_num=$((option_num + 1))
    fi
    
    # Add the two fixed options (direct input and template)
    local direct_option=$((recipe_count + pagination_options + 1))
    local template_option=$((recipe_count + pagination_options + 2))
    local total_options=$((recipe_count + pagination_options + 2))
    
    echo
    read -p "Choose an option (1-$total_options): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $total_options ]]; then
        # Check if it's a recipe selection
        if [[ $choice -le $recipe_count ]]; then
            local selected_recipe=${recipes[$((start + choice - 1))]}
            export SELECTED_RECIPE="$SCRIPT_DIR/recipes/${selected_recipe}.md"
            return 0
        fi
        
        # Check pagination options
        local pagination_start=$((recipe_count + 1))
        if [[ $choice -ge $pagination_start ]] && [[ $choice -lt $direct_option ]]; then
            # This is a pagination option
            local pagination_choice=$((choice - recipe_count))
            
            if [[ $show_more == true ]] && [[ $pagination_choice -eq 1 ]]; then
                # Show more recipes
                export RECIPE_PAGE=$((page + 1))
                return 2
            elif [[ $show_more == true ]] && [[ $show_previous == true ]] && [[ $pagination_choice -eq 2 ]]; then
                # Show previous recipes (when both more and previous are shown)
                export RECIPE_PAGE=$((page - 1))
                return 2
            elif [[ $show_more == false ]] && [[ $show_previous == true ]] && [[ $pagination_choice -eq 1 ]]; then
                # Show previous recipes (when only previous is shown)
                export RECIPE_PAGE=$((page - 1))
                return 2
            fi
        elif [[ $choice -eq $direct_option ]]; then
            # Direct input
            return 3
        elif [[ $choice -eq $template_option ]]; then
            # Create template
            return 4
        fi
    fi
    
    echo "Invalid selection. Please try again."
    return 1
}

# Handle direct project description
handle_direct_input() {
    echo
    print_header "Describe Your Project"
    echo "Tell me what you want to build. Be as detailed as you like:"
    echo "Example: 'A React app with user authentication and a dashboard'"
    echo
    read -p "> " project_description
    
    if [[ -z "$project_description" ]]; then
        print_error "No description provided"
        return 1
    fi
    
    export DIRECT_INPUT="$project_description"
    return 0
}

# Create template scaffold_me.md
create_template() {
    if [[ -f "scaffold_me.md" ]]; then
        print_warning "scaffold_me.md already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Copy the template from the example directory
    local template_file="$SCRIPT_DIR/example/scaffold_me.md"
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "scaffold_me.md"
        print_success "Created template scaffold_me.md"
    else
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    echo
    echo "Next steps:"
    echo "1. Edit scaffold_me.md to describe your project"
    echo "2. Run 'sfme.sh' again to scaffold your project"
    echo
}

# Initialize Claude Code environment
setup_claude_env() {
    print_status "Setting up Claude Code environment..."
    
    # Create .claude directory if it doesn't exist
    mkdir -p .claude/agents
    mkdir -p .claude/commands
    
    # Copy scaffold agent to project .claude/agents directory
    if [[ -f "$SCRIPT_DIR/.claude/agents/scaffold_me" ]]; then
        cp "$SCRIPT_DIR/.claude/agents/scaffold_me" ".claude/agents/scaffold_me"
        print_success "Copied scaffold_me agent to project"
    else
        print_error "Scaffold agent not found in $SCRIPT_DIR/.claude/agents/scaffold_me"
        exit 1
    fi
    
    print_success "Claude Code environment ready"
}

# Start scaffolding process
start_scaffold() {
    local os_type
    os_type=$(detect_os)
    
    setup_claude_env
    
    echo
    print_success "Starting scaffold process!"
    echo
    print_status "Environment info:"
    echo "- OS: $os_type"
    echo "- Docker available: ${SFME_DOCKER_AVAILABLE:-false}"
    echo "- Working directory: $(pwd)"
    echo
    
    # Prepare input for scaffold agent
    local input_context=""
    if [[ -n "${SELECTED_RECIPE:-}" ]]; then
        input_context="Please read the recipe file at '${SELECTED_RECIPE}' and scaffold this project according to its specifications."
    elif [[ -f "scaffold_me.md" ]]; then
        input_context="Please read the scaffold_me.md file in this directory and scaffold this project according to its specifications."
    elif [[ -n "${DIRECT_INPUT:-}" ]]; then
        input_context="Please scaffold a project based on this description: '$DIRECT_INPUT'"
    else
        print_error "No input provided for scaffolding"
        exit 1
    fi
    
    # Add environment context
    local remote_info=""
    if is_remote_session; then
        remote_info="- Remote session: true"
    else
        remote_info="- Remote session: false"
    fi
    
    input_context="$input_context

Environment info:
- OS: $os_type
$remote_info
- Docker available: ${SFME_DOCKER_AVAILABLE:-false}
- IDE preference: ${SELECTED_IDE:-none}
- Working directory: $(pwd)

Please follow the scaffold agent instructions to research current best practices, guide the user through any necessary choices, configure all files properly (including IDE setup for ${SELECTED_IDE:-none}), and create complete documentation."
    
    # Start the scaffold process
    if command_exists "claude"; then
        print_status "Setting up project context for Claude Code..."
        
        # Read the recipe content if available
        local recipe_content=""
        if [[ -n "${SELECTED_RECIPE:-}" ]] && [[ -f "$SELECTED_RECIPE" ]]; then
            recipe_content=$(cat "$SELECTED_RECIPE")
        elif [[ -f "scaffold_me.md" ]]; then
            recipe_content=$(cat "scaffold_me.md")
        elif [[ -n "${DIRECT_INPUT:-}" ]]; then
            recipe_content="# Project Description

$DIRECT_INPUT"
        fi
        
        # Create a CLAUDE.md file with instructions and recipe content
        cat > CLAUDE.md << EOF
# Scaffold Me Project Setup

## IMMEDIATE ACTION REQUIRED
**START SCAFFOLDING THIS PROJECT NOW!**

You are the Claude Code scaffold agent. Begin implementation immediately:

1. **START NOW**: Read the recipe below and begin creating the project structure
2. **Research Current Practices**: Look up the latest installation and setup procedures
3. **Create Project Structure**: Set up the complete project based on the recipe
4. **Configure IDE**: Set up the project for $SELECTED_IDE
5. **Generate Documentation**: Create comprehensive README.md
6. **Verify Setup**: Ensure everything works and is ready for development

## Environment Context
- OS: $os_type
- Remote session: $(is_remote_session && echo "true" || echo "false")
- Docker available: ${SFME_DOCKER_AVAILABLE:-false}
- IDE preference: ${SELECTED_IDE:-none}
- Working directory: $(pwd)

## Project Recipe

$recipe_content

---

**DO NOT WAIT FOR APPROVAL - BEGIN SCAFFOLDING NOW!**

Create your TodoWrite list and start implementing the project based on the recipe above.

EOF

        print_success "Created project context files:"
        echo "  - CLAUDE.md (complete instructions and recipe for Claude)"
        echo
        print_status "Starting Claude Code..."
        echo "Once Claude Code starts, it will automatically run the @scaffold_me agent."
        echo
        
        # Start Claude Code normally without piping
        claude @scaffold_me
    else
        print_error "Claude Code not found. Please install it first."
        exit 1
    fi
}

# Main menu logic
show_main_menu() {
    local os_type
    os_type=$(detect_os)
    
    print_header "Scaffold Me - AI-Powered Project Scaffolding"
    echo "Running on $os_type in $(pwd)"
    
    if is_remote_session; then
        echo "Remote development session detected"
    fi
    echo
    
    # Check if scaffold_me.md exists
    if [[ -f "scaffold_me.md" ]]; then
        print_status "Found scaffold_me.md in current directory"
        echo
        read -p "Shall I create the scaffold project from this file? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo
            print_status "Showing other options..."
        else
            start_scaffold
            return
        fi
    fi
    
    # Show recipe menu
    local recipes
    mapfile -t recipes < <(scan_recipes)
    
    while true; do
        get_recipe_selection "${recipes[@]}"
        local result=$?
        case $result in
            0)
                # Recipe selected
                start_scaffold
                return
                ;;
            1)
                # Invalid selection, try again
                continue
                ;;
            2)
                # Pagination requested, continue loop
                continue
                ;;
            3)
                # Direct input
                if handle_direct_input; then
                    start_scaffold
                    return
                fi
                ;;
            4)
                # Create template
                create_template
                return
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
Scaffold Me - AI-Powered Project Scaffolding

USAGE:
    sfme.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    --ide <type>            Override IDE preference for this project
    
IDE TYPES:
    vscode-claude           VSCode + Claude Code (recommended)
    cursor-claude           Cursor + Claude Code  
    vscode                  VSCode only
    cursor                  Cursor only
    claude                  Claude Code only

PREREQUISITES:
    - Claude Code installed and authenticated (run 'claude login' first)
    - Git installed
    - At least one IDE (VSCode or Cursor recommended)

OPTIONAL:
    - Docker & docker-compose (for MCP services)

AUTHENTICATION:
    Before using this script, ensure Claude Code is authenticated:
    
    Local development:
      claude login
    
    Remote development:
      - Authenticate Claude Code on your local machine first
      - Ensure authentication is available on the remote system
      - Or run Claude Code from local machine pointing to remote directory

HOW IT WORKS:
    1. Run sfme.sh in your project directory
    2. Choose IDE preference (asked once)
    3. Choose from available recipes or describe your project
    4. The AI scaffold agent will build your project with proper IDE setup
    5. Start developing immediately!

EXAMPLES:
    # Interactive menu with global IDE preference
    sfme.sh

    # Override IDE for this project
    sfme.sh --ide cursor-claude

    # Get help
    sfme.sh --help

CONFIGURATION:
    Global preferences stored in: ~/.scaffold_me/config

MORE INFO:
    See README.md for detailed information.
EOF
}

# Main execution
main() {
    check_prerequisites
    get_ide_preference
    check_docker
    show_main_menu
}

# Global variables
IDE_OVERRIDE=""
CONFIG_DIR="$HOME/.scaffold_me"
CONFIG_FILE="$CONFIG_DIR/config"

# Create config directory if needed
ensure_config_dir() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
}

# Get global IDE preference
get_global_ide_preference() {
    if [[ -f "$CONFIG_FILE" ]]; then
        grep "^IDE_PREFERENCE=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2
    fi
}

# Set global IDE preference
set_global_ide_preference() {
    local choice="$1"
    ensure_config_dir
    
    # Remove existing preference and add new one
    if [[ -f "$CONFIG_FILE" ]]; then
        grep -v "^IDE_PREFERENCE=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" 2>/dev/null || true
        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "IDE_PREFERENCE=$choice" >> "$CONFIG_FILE"
}

# Detect if we're in a remote session
is_remote_session() {
    # Check for SSH session indicators
    [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]] || [[ -n "${SSH_CONNECTION:-}" ]] || [[ "${TERM_PROGRAM:-}" == "vscode" ]] || [[ -n "${VSCODE_IPC_HOOK_CLI:-}" ]] || [[ -n "${CURSOR_SESSION:-}" ]]
}

# Detect installed IDEs and Claude Code
detect_available_tools() {
    local available=()
    
    # Check for Claude Code (always required)
    local has_claude=false
    command_exists "claude" && has_claude=true
    
    # If we're in a remote session or can't detect local IDEs reliably,
    # show all IDE options and let the user choose
    if is_remote_session; then
        print_status "Remote development session detected"
        
        if [[ "$has_claude" == true ]]; then
            available+=("vscode-claude" "cursor-claude" "vscode" "cursor" "claude")
        else
            available+=("vscode" "cursor")
        fi
    else
        # Local session - detect what's actually installed
        local has_vscode=false
        local has_cursor=false
        
        command_exists "code" && has_vscode=true
        command_exists "cursor" && has_cursor=true
        
        # Build available options based on what's installed locally
        if [[ "$has_vscode" == true ]] && [[ "$has_claude" == true ]]; then
            available+=("vscode-claude")
        fi
        if [[ "$has_cursor" == true ]] && [[ "$has_claude" == true ]]; then
            available+=("cursor-claude")
        fi
        if [[ "$has_vscode" == true ]]; then
            available+=("vscode")
        fi
        if [[ "$has_cursor" == true ]]; then
            available+=("cursor")
        fi
        if [[ "$has_claude" == true ]]; then
            available+=("claude")
        fi
        
        # If no local IDEs detected, show all options anyway
        if [[ ${#available[@]} -eq 0 ]] || [[ ${#available[@]} -eq 1 && "${available[0]}" == "claude" ]]; then
            print_warning "No local IDEs detected - showing all options"
            if [[ "$has_claude" == true ]]; then
                available=("vscode-claude" "cursor-claude" "vscode" "cursor" "claude")
            else
                available=("vscode" "cursor")
            fi
        fi
    fi
    
    printf '%s\n' "${available[@]}"
}

# Choose IDE setup
choose_ide_setup() {
    echo
    print_header "Development Environment Setup"
    
    if is_remote_session; then
        echo "Remote development session detected."
        echo "Choose the IDE you're using on your local machine:"
    else
        echo "Choose your preferred development environment:"
    fi
    echo
    
    local available
    mapfile -t available < <(detect_available_tools)
    
    local options=()
    local descriptions=()
    
    # Build menu based on available tools
    for tool in "${available[@]}"; do
        case "$tool" in
            "vscode-claude")
                options+=("vscode-claude")
                descriptions+=("VSCode + Claude Code (recommended for AI assistance)")
                ;;
            "cursor-claude")
                options+=("cursor-claude")
                descriptions+=("Cursor + Claude Code (AI-first IDE with Claude)")
                ;;
            "vscode")
                options+=("vscode")
                descriptions+=("VSCode only (traditional development)")
                ;;
            "cursor")
                options+=("cursor")
                descriptions+=("Cursor only (AI-first IDE)")
                ;;
            "claude")
                options+=("claude")
                descriptions+=("Claude Code only (terminal-based)")
                ;;
        esac
    done
    
    if [[ ${#options[@]} -eq 0 ]]; then
        print_error "No supported development tools found"
        echo "Please install one of: VSCode, Cursor, or Claude Code"
        exit 1
    fi
    
    # Display options
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${descriptions[i]}"
    done
    echo
    
    if is_remote_session; then
        echo "Note: For remote development, the scaffold will configure the project"
        echo "for your chosen IDE even if it's not installed on this server."
        echo
    fi
    
    # Get user choice
    while true; do
        read -p "Choose option (1-${#options[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            local selected="${options[$((choice-1))]}"
            
            # Ask if global, don't ask again, or project-only
            echo
            echo "How would you like to handle this IDE preference?"
            echo "  y - Set globally for all projects"
            echo "  d - Don't ask again (use for all projects without saving globally)"
            echo "  n - Use for this project only (default - will ask again next time)"
            echo
            read -p "Choose (y/d/N): " -n 1 -r
            echo
            case "$REPLY" in
                [Yy])
                    set_global_ide_preference "$selected"
                    print_success "Set global IDE preference: $selected"
                    ;;
                [Dd])
                    export SFME_IDE_NO_ASK="$selected"
                    print_status "Using '$selected' for all projects (not asking again this session)"
                    ;;
                *)
                    print_status "Using '$selected' for this project only"
                    ;;
            esac
            
            export SELECTED_IDE="$selected"
            return 0
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Get IDE preference (global, override, or ask)
get_ide_preference() {
    # Check for command line override first
    if [[ -n "$IDE_OVERRIDE" ]]; then
        export SELECTED_IDE="$IDE_OVERRIDE"
        print_status "Using IDE override: $IDE_OVERRIDE"
        return
    fi
    
    # Check for "don't ask again" session preference
    if [[ -n "${SFME_IDE_NO_ASK:-}" ]]; then
        export SELECTED_IDE="$SFME_IDE_NO_ASK"
        print_status "Using session IDE preference: $SFME_IDE_NO_ASK"
        return
    fi
    
    # Check for global preference
    local global_pref
    global_pref=$(get_global_ide_preference)
    if [[ -n "$global_pref" ]]; then
        export SELECTED_IDE="$global_pref"
        print_status "Using global IDE preference: $global_pref"
        return
    fi
    
    # No preference set, ask user
    choose_ide_setup
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --ide)
            if [[ -n "$2" ]]; then
                # Validate IDE option
                case "$2" in
                    vscode-claude|cursor-claude|vscode|cursor|claude)
                        IDE_OVERRIDE="$2"
                        shift 2
                        ;;
                    *)
                        print_error "Invalid IDE option: $2"
                        echo "Valid options: vscode-claude, cursor-claude, vscode, cursor, claude"
                        exit 1
                        ;;
                esac
            else
                print_error "--ide requires a value"
                echo "Valid options: vscode-claude, cursor-claude, vscode, cursor, claude"
                exit 1
            fi
            ;;
        --ide=*)
            local ide_value="${1#*=}"
            case "$ide_value" in
                vscode-claude|cursor-claude|vscode|cursor|claude)
                    IDE_OVERRIDE="$ide_value"
                    shift
                    ;;
                *)
                    print_error "Invalid IDE option: $ide_value"
                    echo "Valid options: vscode-claude, cursor-claude, vscode, cursor, claude"
                    exit 1
                    ;;
            esac
            ;;
        "")
            break
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h for help"
            exit 1
            ;;
    esac
done



# Execute main if no arguments processed above
if [[ $# -eq 0 ]]; then
    main
fi