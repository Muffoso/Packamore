#!/bin/bash

# Push to both public and private repos simultaneously
# Public repo: Packamore (code only)
# Private repo: Packamore_private (DESIGN_GUIDELINES_PRIVATE, Research, workflows)
# Usage: ./push-all.sh "Your commit message"

if [ -z "$1" ]; then
  echo "Usage: ./push-all.sh \"Your commit message\""
  exit 1
fi

COMMIT_MSG="$1"

echo "🔄 Committing changes..."
git add -A
git commit -m "$COMMIT_MSG"

echo "📤 Pushing to public repo (master)..."
git push origin master

echo "🔒 Pushing to private repo (DESIGN_GUIDELINES_PRIVATE, Research, workflows)..."
git subtree push --prefix DESIGN_GUIDELINES_PRIVATE https://github.com/Muffoso/Packamore_private.git main

echo "✅ Done! Pushed to both repos."
echo "   Public: Packamore (all except Research, workflows, DESIGN_GUIDELINES_PRIVATE)"
echo "   Private: Packamore_private (DESIGN_GUIDELINES_PRIVATE with Research & workflows)"
