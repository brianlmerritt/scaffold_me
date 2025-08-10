# Scaffold Me

An AI-powered project scaffolding system that creates complete development environments from simple recipe descriptions.

## What Is This?

Instead of wrestling with complex templates or boilerplate generators, just describe your project in plain English. Scaffold Me uses Claude Code to understand your requirements and build the entire project structure, complete with modern best practices and development tools.

## Quick Start

### 1. Prerequisites

- **Claude Code** installed ([get it here](https://docs.anthropic.com/en/docs/claude-code))
- **Git** installed
- **Docker** (optional, for MCP services and containerized development)

### 2. Install Scaffold Me

```bash
# Clone this repository
git clone https://github.com/your-org/scaffold_me.git
cd scaffold_me

# Make sfme.sh executable
chmod +x sfme.sh

# Add to your PATH (optional)
export PATH="$PATH:$(pwd)"
```

### 3. Create Your Project

```bash
# Create a new project directory
mkdir my-awesome-project
cd my-awesome-project

# Write a simple recipe
cat > scaffold_me.md << 'EOF'
# My Awesome Project

I need a web application that:
- Has a modern frontend
- Includes user authentication
- Stores data in a database
- Is ready for development

## Technical Preferences
- Language: any
- Database: any
- Style: modern
EOF

# Run the scaffold
sfme.sh
```

### 4. Watch the Magic

The Scaffold Agent will:
1. Read your recipe
2. Ask clarifying questions
3. Propose a technology stack
4. Create the entire project structure
5. Set up the development environment
6. Configure MCP services (if Docker available)

### 5. Start Developing

```bash
# If Docker was set up:
docker-compose up

# If not using Docker:
npm start  # or python main.py, or whatever was created

# Open in your editor:
code .
```

## Recipe Format

Recipes are simple markdown files that describe what you want:

```markdown
# Project Name

Brief description of what you're building.

## What I Want
- Feature 1
- Feature 2
- Feature 3

## Technical Preferences (optional)
- Language: [preference or "any"]
- Database: [preference or "any"]
- Style: [modern/classic/minimal]

## Must Have
- Critical feature
- Another critical feature

## Nice to Have
- Optional feature
- Another optional feature
```

## Example Recipes

### Simple Web App
```markdown
# My Blog

A personal blog where I can write and publish articles.

## What I Want
- Write posts in markdown
- Categorize and tag posts
- Simple, fast loading pages
- Admin interface for managing content

## Technical Preferences
- Language: any
- Database: something simple
- Style: minimal and fast
```

### REST API
```markdown
# User Management API

A REST API for managing users and authentication.

## What I Want
- User registration and login
- JWT token authentication
- Password reset functionality
- User profile management
- Admin user management

## Technical Preferences
- Language: Python or Node.js
- Database: PostgreSQL
- Style: well-documented API
```

### CLI Tool
```markdown
# File Organizer

A command-line tool that organizes files by type and date.

## What I Want
- Scan directories for files
- Move files to organized folders
- Support undo operations
- Configuration file for rules
- Progress indicators

## Technical Preferences
- Language: any (but prefer something with good CLI libraries)
```

## What Gets Created

Depending on your recipe, you might get:

### Web Applications
- Frontend (React, Vue, Svelte, etc.)
- Backend API (Node.js, Python, Go, etc.)
- Database setup (PostgreSQL, SQLite, etc.)
- Authentication system
- Development scripts
- Docker configuration
- MCP services for enhanced development

### APIs
- REST endpoints
- Database models
- Authentication middleware
- API documentation
- Testing setup
- Docker configuration

### CLI Tools
- Argument parsing
- Configuration management
- Error handling
- Testing framework
- Build scripts

## Smart Defaults

When you say "any", Scaffold Me chooses modern, well-supported technologies:

- **Frontend**: React with TypeScript
- **Backend**: Node.js with TypeScript or Python with FastAPI
- **Database**: PostgreSQL for complex apps, SQLite for simple ones
- **Styling**: Tailwind CSS
- **Testing**: Jest/Vitest for JavaScript, pytest for Python
- **Containerization**: Docker with docker-compose

## MCP Services

When Docker is available, Scaffold Me can configure MCP (Model Context Protocol) services to enhance your development experience:

- **Filesystem MCP**: Enhanced file operations
- **Browser MCP**: Web automation and testing
- **Database MCP**: Database introspection and operations

These run locally in containers and integrate with Claude Code for powerful development workflows.

## Cross-Platform Support

Scaffold Me works on:
- **Linux** (bash)
- **macOS** (bash) 
- **Windows** (Git Bash)

No WSL required on Windows!

## Philosophy

### What This IS
- A smart project starter
- An AI that understands project needs
- A development environment builder
- A time saver that uses modern best practices

### What This Is NOT
- A template engine
- A package manager
- A deployment tool
- A CI/CD system
- A code generator for business logic

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

MIT License - see [LICENSE](LICENSE) file.

---

**Built with ❤️ and Claude Code**