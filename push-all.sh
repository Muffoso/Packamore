#!/bin/bash

# Push to both Packamore and Packamore_private repos
# This script runs push.sh in both directories and handles both commits/pushes
#
# Usage:
#   ./push-all.sh                      # Auto-generate commit messages for both repos
#   ./push-all.sh "Custom message"     # Use custom message for both repos

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CUSTOM_MSG="$1"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Pushing to both Packamore and Packamore_private${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if Packamore has changes
cd "$(dirname "$0")/Packamore" 2>/dev/null || cd .
if [ -z "$(git status -s)" ]; then
  echo -e "${YELLOW}ℹ️  No changes in Packamore${NC}"
  PUSH_PACKAMORE=false
else
  PUSH_PACKAMORE=true
fi

# Check if Packamore_private has changes
cd "$(dirname "$0")/../Packamore_private" 2>/dev/null
if [ -z "$(git status -s)" ]; then
  echo -e "${YELLOW}ℹ️  No changes in Packamore_private${NC}"
  PUSH_PRIVATE=false
else
  PUSH_PRIVATE=true
fi

cd "$(dirname "$0")"

# If no changes in either repo, exit
if [ "$PUSH_PACKAMORE" = false ] && [ "$PUSH_PRIVATE" = false ]; then
  echo -e "${RED}❌ No changes to commit in either repo. Exiting.${NC}"
  exit 0
fi

echo ""
echo -e "${BLUE}📤 Starting push operations...${NC}"
echo ""

# Push Packamore
if [ "$PUSH_PACKAMORE" = true ]; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}▶ Packamore${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  if [ -z "$CUSTOM_MSG" ]; then
    ./push.sh
  else
    ./push.sh "$CUSTOM_MSG"
  fi

  echo ""
else
  echo -e "${YELLOW}⊘ Skipping Packamore (no changes)${NC}"
  echo ""
fi

# Push Packamore_private
if [ "$PUSH_PRIVATE" = true ]; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}▶ Packamore_private${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  cd ../Packamore_private
  if [ -z "$CUSTOM_MSG" ]; then
    ./push.sh
  else
    ./push.sh "$CUSTOM_MSG"
  fi

  echo ""
else
  echo -e "${YELLOW}⊘ Skipping Packamore_private (no changes)${NC}"
  echo ""
fi

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ All done! Both repos pushed successfully.${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
