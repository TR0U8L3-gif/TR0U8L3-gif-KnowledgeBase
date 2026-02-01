#!/bin/bash

# Script to build Flutter web app and prepare it for GitHub Pages deployment
# This script:
# 1. Builds the Flutter web app
# 2. Copies the build output to web/build directory
# 3. Removes the base href tag from index.html

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Flutter web build process...${NC}"

# Step 1: Build Flutter web
echo -e "${YELLOW}Step 1: Building Flutter web app...${NC}"
flutter build web --release

if [ $? -ne 0 ]; then
    echo -e "${RED}Flutter build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter build completed successfully${NC}"

# Step 2: Copy build output to web/build
echo -e "${YELLOW}Step 2: Copying build output to web/build...${NC}"

# Create web/build directory if it doesn't exist
mkdir -p web/build

# Remove old files in web/build
rm -rf web/build/*

# Copy all files from build/web to web/build
cp -r build/web/* web/build/

echo -e "${GREEN}✓ Files copied successfully${NC}"

# Step 3: Modify index.html to remove base href
echo -e "${YELLOW}Step 3: Removing base href from index.html...${NC}"

INDEX_FILE="web/build/index.html"

if [ -f "$INDEX_FILE" ]; then
    # Remove the line containing <base href="/" />
    sed -i.bak '/<base href="\/".*/d' "$INDEX_FILE"
    
    # Remove backup file
    rm -f "$INDEX_FILE.bak"
    
    echo -e "${GREEN}✓ Base href removed from index.html${NC}"
else
    echo -e "${RED}Error: index.html not found at $INDEX_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}Build and deployment preparation complete!${NC}"
echo -e "${GREEN}Files are ready in web/build directory${NC}"
echo -e "${GREEN}==================================${NC}"
