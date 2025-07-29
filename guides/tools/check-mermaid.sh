#!/bin/bash
# Mermaid Syntax Checker using Docker Container
# Similar to PlantUML checker - keeps container running for better performance

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Check if file path is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No file path provided${NC}"
    echo "Usage: $0 <mermaid-file>"
    exit 1
fi

FILE_PATH="$1"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${RED}Error: File not found: $FILE_PATH${NC}"
    exit 1
fi

# Get absolute path
ABSOLUTE_PATH=$(realpath "$FILE_PATH")
FILE_NAME=$(basename "$ABSOLUTE_PATH")

echo -e "\n${CYAN}Checking Mermaid syntax for: $FILE_NAME${NC}"
echo -e "${GRAY}$(printf '=%.0s' {1..60})${NC}"

# Check if mermaid container is running
CONTAINER_RUNNING=$(docker ps --filter "name=mermaid-cli" --format "{{.Names}}" 2>/dev/null)

if [ -z "$CONTAINER_RUNNING" ]; then
    echo -e "${RED}Error: Mermaid CLI container is not running.${NC}"
    echo -e "${YELLOW}Please follow the setup instructions in the Mermaid guide to start the container.${NC}"
    echo -e "\n${CYAN}Quick setup commands:${NC}"
    echo ""
    echo -e "${GREEN}# 1. Start container with root privileges (port 48080)${NC}"
    echo -e "${NC}docker run -d --rm --name mermaid-cli -u root -p 48080:8080 --entrypoint sh minlag/mermaid-cli:latest -c \"while true;do sleep 3600; done\"${NC}"
    echo ""
    echo -e "${GREEN}# 2. Install Chromium and dependencies${NC}"
    echo -e "${NC}docker exec mermaid-cli sh -c \"apk add --no-cache chromium chromium-chromedriver nss freetype harfbuzz ca-certificates ttf-freefont\"${NC}"
    echo ""
    echo -e "${GREEN}# 3. Create Puppeteer configuration${NC}"
    echo -e "${NC}docker exec mermaid-cli sh -c \"echo '{\\\"executablePath\\\": \\\"/usr/bin/chromium-browser\\\", \\\"args\\\": [\\\"--no-sandbox\\\", \\\"--disable-setuid-sandbox\\\", \\\"--disable-dev-shm-usage\\\"]}' > /tmp/puppeteer-config.json\"${NC}"
    echo ""
    exit 1
fi

# Set Puppeteer configuration file path
PUPPETEER_CONFIG_FILE="/tmp/puppeteer-config.json"

# Generate unique temp filename
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
PID=$$
TEMP_FILE="/tmp/mermaid_${TIMESTAMP}_${PID}.mmd"
OUTPUT_FILE="/tmp/mermaid_${TIMESTAMP}_${PID}.svg"

# Copy file to container
echo -e "${GRAY}Copying file to container...${NC}"
docker cp "$ABSOLUTE_PATH" "mermaid-cli:$TEMP_FILE" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to copy file to container${NC}"
    exit 1
fi

# Run syntax check with Puppeteer configuration
echo -e "${GRAY}Running syntax check...${NC}"
OUTPUT=$(docker exec mermaid-cli sh -c "cd /home/mermaidcli && node_modules/.bin/mmdc -i '$TEMP_FILE' -o '$OUTPUT_FILE' -p '$PUPPETEER_CONFIG_FILE' -q" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}Success: Mermaid syntax is valid!${NC}"
else
    echo -e "\n${RED}Error: Mermaid syntax validation failed!${NC}"
    echo -e "\n${RED}Error details:${NC}"
    
    # Parse and display error messages
    while IFS= read -r line; do
        if [[ $line == *"Error:"* ]] || [[ $line == *"Parse error"* ]] || [[ $line == *"Expecting"* ]] || [[ $line == *"Syntax error"* ]]; then
            echo -e "  ${RED}$line${NC}"
        elif [[ $line == *"line"* ]] && [[ $line =~ [0-9]+ ]]; then
            echo -e "  ${YELLOW}$line${NC}"
        elif [[ ! -z "$line" ]]; then
            echo -e "  ${RED}$line${NC}"
        fi
    done <<< "$OUTPUT"
    
    # Clean up and exit with error
    docker exec mermaid-cli rm -f "$TEMP_FILE" "$OUTPUT_FILE" >/dev/null 2>&1
    exit 1
fi

# Clean up temp files
echo -e "\n${GRAY}Cleaning up...${NC}"
docker exec mermaid-cli rm -f "$TEMP_FILE" "$OUTPUT_FILE" >/dev/null 2>&1

echo -e "\n${CYAN}Validation complete!${NC}"

# Note: Container is kept running for subsequent checks
# To stop: docker stop mermaid-cli && docker rm mermaid-cli