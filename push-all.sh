#!/bin/bash

# Push to both public and private repos simultaneously with auto-generated commit messages
# Public repo: Packamore (code only)
# Private repo: Packamore_private (DESIGN_GUIDELINES_PRIVATE, Research, workflows)
#
# Usage:
#   ./push-all.sh                      # Auto-generate commit message from changes
#   ./push-all.sh "Custom message"     # Use custom commit message

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if there are any changes
if ! git diff-index --quiet HEAD --; then
  STAGED=true
else
  STAGED=false
fi

if [ -z "$(git status -s)" ]; then
  echo -e "${RED}❌ No changes to commit. Exiting.${NC}"
  exit 0
fi

# Generate commit message if not provided
if [ -z "$1" ]; then
  echo -e "${BLUE}📊 Analyzing changes...${NC}"

  # Get list of changed files (including untracked)
  CHANGED_FILES=$(git status -s | cut -c 4-)

  # Categorize changes
  ADDED=$(git status -s | grep -E "^(A|\?\?)" | wc -l)
  MODIFIED=$(git status -s | grep "^M" | wc -l)
  DELETED=$(git status -s | grep "^D" | wc -l)

  # Generate commit message
  COMMIT_PARTS=()

  if [ $ADDED -gt 0 ]; then
    COMMIT_PARTS+=("Add $ADDED file(s)")
  fi

  if [ $MODIFIED -gt 0 ]; then
    COMMIT_PARTS+=("Update $MODIFIED file(s)")
  fi

  if [ $DELETED -gt 0 ]; then
    COMMIT_PARTS+=("Remove $DELETED file(s)")
  fi

  # Join parts with " and "
  COMMIT_MSG=$(IFS=' and '; echo "${COMMIT_PARTS[*]}")

  # Add details if there are changed files
  echo -e "${YELLOW}Changed files:${NC}"
  echo "$CHANGED_FILES" | head -5
  if [ $(echo "$CHANGED_FILES" | wc -l) -gt 5 ]; then
    echo "... and $(( $(echo "$CHANGED_FILES" | wc -l) - 5 )) more"
  fi

  echo ""
  echo -e "${YELLOW}📝 Auto-generated commit message:${NC}"
  echo "   $COMMIT_MSG"
  echo ""
  read -p "Proceed with this message? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
else
  COMMIT_MSG="$1"
  echo -e "${YELLOW}📝 Using custom commit message:${NC}"
  echo "   $COMMIT_MSG"
fi

# Stage all changes
echo -e "${BLUE}🔄 Staging all changes...${NC}"
git add -A

# Create commit with footer
echo -e "${BLUE}💾 Creating commit...${NC}"
COMMIT_BODY="$COMMIT_MSG"$'\n\nCo-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>'
git commit -m "$COMMIT_BODY"

# Push to public repo
echo -e "${BLUE}📤 Pushing to public repo (master)...${NC}"
if git push origin master; then
  echo -e "${GREEN}✅ Public repo pushed successfully${NC}"
else
  echo -e "${RED}❌ Failed to push to public repo${NC}"
  exit 1
fi

# Push to private repo
echo -e "${BLUE}🔒 Pushing to private repo (DESIGN_GUIDELINES_PRIVATE)...${NC}"
if git subtree push --prefix DESIGN_GUIDELINES_PRIVATE https://github.com/Muffoso/Packamore_private.git main; then
  echo -e "${GREEN}✅ Private repo pushed successfully${NC}"
else
  echo -e "${RED}❌ Failed to push to private repo${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ All done! Pushed to both repos.${NC}"
echo -e "${GREEN}   Public: Packamore (code only)${NC}"
echo -e "${GREEN}   Private: Packamore_private (guidelines, research, workflows)${NC}"
