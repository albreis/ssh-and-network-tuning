#!/bin/bash

# SSH and Network Tuning Repository Update Script
# This script automatically updates the ssh-and-network-tuning repository
# before executing any substantial task

set -e  # Exit on any error

REPO_PATH="/projects/69b235ed78cc8ded7792d113/ssh-and-network-tuning"
PROJECT_ROOT="/projects/69b235ed78cc8ded7792d113"

echo "🔄 Starting automatic repository update..."

# Check if repository exists
if [ ! -d "$REPO_PATH" ]; then
    echo "❌ Error: Repository not found at $REPO_PATH"
    exit 1
fi

# Navigate to repository
cd "$REPO_PATH"

echo "📍 Current location: $(pwd)"

# Check git status
echo "🔍 Checking repository status..."
git status --porcelain

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: There are uncommitted changes in the repository"
    echo "📝 Uncommitted changes:"
    git status --short
    echo ""
    echo "🤔 Please commit or stash these changes before proceeding"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Update cancelled by user"
        exit 1
    fi
fi

# Fetch latest changes
echo "🌐 Fetching latest changes from remote..."
git fetch origin

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "🌿 Current branch: $CURRENT_BRANCH"

# Pull latest changes
echo "⬇️  Pulling latest changes..."
if git pull origin "$CURRENT_BRANCH"; then
    echo "✅ Repository updated successfully!"
else
    echo "❌ Error: Failed to pull latest changes"
    echo "🔧 Please resolve any conflicts manually"
    exit 1
fi

# Return to project root
cd "$PROJECT_ROOT"
echo "📍 Returned to project root: $(pwd)"

echo "🎉 Repository update completed successfully!"
echo "📚 ssh-and-network-tuning repository is now up to date"