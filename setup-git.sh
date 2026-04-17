#!/bin/bash

# Git Setup Script for MagicMirror Setup Project
# Run this after initial project creation to set up git repository

set -e

echo "🚀 Setting up Git repository for MagicMirror Setup"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed"
    exit 1
fi

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already initialized"
fi

# Create .gitignore if it doesn't exist (this should already exist)
if [ ! -f ".gitignore" ]; then
    echo "❌ Error: .gitignore not found"
    exit 1
fi

# Add all files
echo "📝 Adding files to git..."
git add .

# Create initial commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: MagicMirror Setup v1.0.0

- Complete installation script with automated setup
- Automatic OS, Docker, and module updates via systemd timers
- Flask WebUI for management on port 8080
- Module management scripts (install/remove/update)
- Display orientation configuration
- Boot splash screen support
- Systemd service integration
- Comprehensive documentation
- GitHub Actions workflows for CI/CD and releases
- Docker Compose test environment
- Example configurations and modules
" || echo "ℹ️  Commit already exists or no changes to commit"

# Set main branch
echo "🔀 Setting main branch..."
git branch -M main

echo ""
echo "✅ Git repository setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Create GitHub repository: gh repo create twicemind/magicmirror-setup --public"
echo "   Or visit: https://github.com/new"
echo ""
echo "2. Add remote origin:"
echo "   git remote add origin https://github.com/twicemind/magicmirror-setup.git"
echo ""
echo "3. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "4. Create first release tag:"
echo "   git tag -a v1.0.0 -m 'Release version 1.0.0'"
echo "   git push origin v1.0.0"
echo ""
echo "🎉 Ready to push to GitHub!"
