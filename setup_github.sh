#!/bin/bash

# Setup script for pushing Springfield City Government Snowflake AI Demo to GitHub
# This script helps initialize and push the demo repository to your GitHub account

echo "🚀 Setting up Springfield City Government Snowflake AI Demo for GitHub"
echo "GitHub Account: sfc-gh-mvanmeurer"
echo "Repository: https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git"
echo ""

# Configure Git with your Snowflake email
echo "⚙️  Configuring Git with your Snowflake email..."
git config user.email "michael.vanmeurer@snowflake.com"
git config user.name "Michael Van Meurer"
echo "✅ Git configured with michael.vanmeurer@snowflake.com"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Add all files to git
echo "📦 Adding all files to Git..."
git add .

# Create initial commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: Springfield City Government Snowflake AI Demo

- Complete government-focused data model transformation
- 8 government documents across 5 departments
- 3 SQL scripts for database setup, semantic views, and AI agent
- Comprehensive implementation guide
- Ready for Snowflake Intelligence demo deployment"

# Add remote origin (if not already added)
echo "🔗 Setting up remote repository..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ Successfully pushed to GitHub!"
echo "🌐 Repository URL: https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git"
echo ""
echo "📋 Next Steps:"
echo "1. Verify the repository is accessible at the URL above"
echo "2. Follow the IMPLEMENTATION_GUIDE.md for Snowflake deployment"
echo "3. Use the Git integration in Snowflake to automatically load data"
echo ""
echo "🎯 Demo Features Ready:"
echo "- Government data model (13 dimensions + 4 facts + 3 CRM tables)"
echo "- 8 government documents for Cortex Search"
echo "- 4 semantic views for natural language queries"
echo "- AI agent configuration for multi-tool capabilities"
echo "- Complete implementation guide for Snowflake deployment"
