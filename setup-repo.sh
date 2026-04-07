#!/bin/bash
# Initialize Git Repository and Push to GitHub

set -e

echo "🚀 VendorQuote - Git Repository Setup"
echo "======================================"
echo ""

# Check if we're already in a git repo
if [ -d .git ]; then
  echo "⚠️  Git repository already exists!"
  echo "This script is for initial setup only."
  exit 1
fi

# Prompt for GitHub repo URL
echo "Enter your GitHub repository URL (e.g., https://github.com/username/vendorquote.git):"
read REPO_URL

if [ -z "$REPO_URL" ]; then
  echo "❌ Repository URL is required"
  exit 1
fi

echo ""
echo "📦 Initializing Git repository..."
git init

echo ""
echo "📝 Adding files..."
git add .

echo ""
echo "💾 Creating initial commit..."
git commit -m "Initial commit: VendorQuote deliberately insecure container for training

- Intentionally vulnerable Node.js application for container security training
- Command injection vulnerability for demonstration purposes
- Embedded fake credentials and sensitive data
- Educational tool for CrowdStrike Cloud Security labs
- NOT for production use

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

echo ""
echo "🌿 Creating main branch..."
git branch -M main

echo ""
echo "🔗 Adding remote origin..."
git remote add origin "$REPO_URL"

echo ""
echo "⬆️  Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Repository setup complete!"
echo ""
echo "📍 Your repository: $REPO_URL"
echo ""
echo "Next steps:"
echo "  1. Visit your GitHub repository"
echo "  2. Add topics/tags: security, docker, container-security, training, educational"
echo "  3. Review the Security tab to ensure SECURITY.md is recognized"
echo "  4. Consider adding a repository description"
echo ""
echo "⚠️  IMPORTANT REMINDERS:"
echo "  - Add prominent security warnings to the GitHub description"
echo "  - Consider adding 'intentionally-vulnerable' as a topic"
echo "  - Review GitHub's security advisories settings"
echo ""
