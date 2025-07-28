#!/bin/bash

# PlantUML file syntax checker script
# Usage: ./check_plantuml.sh <file_to_check>

# Check parameters
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file_to_check>"
    echo "Example: $0 diagram.puml"
    exit 1
fi

# File to check parameter
CHECK_FILE="$1"

# Check if file exists
if [ ! -f "$CHECK_FILE" ]; then
    echo "Error: File '$CHECK_FILE' does not exist."
    exit 1
fi

# 1. Generate unique filename (prevent conflicts)
TEMP_FILE="/tmp/puml_$(date +%s)_$$.puml"

# 2. Copy file
echo "Copying file to Docker container..."
docker cp "$CHECK_FILE" plantuml:"$TEMP_FILE"

# 3. Find JAR file location
echo "Finding PlantUML JAR file location..."
JAR_PATH=$(docker exec plantuml find / -name "plantuml*.jar" 2>/dev/null | head -1)

if [ -z "$JAR_PATH" ]; then
    echo "Error: PlantUML JAR file not found."
    exit 1
fi

# 4. Syntax check
echo "Running PlantUML syntax check..."
docker exec plantuml java -jar "$JAR_PATH" -checkonly "$TEMP_FILE"

# 5. Detailed error check (if needed)
echo "Checking detailed error information..."
docker exec plantuml sh -c "cd /tmp && java -jar $JAR_PATH -failfast -v $TEMP_FILE 2>&1 | grep -E 'Error line'"

# 6. Clean up temporary file
echo "Cleaning up temporary files..."
docker exec -u root plantuml rm -f "$TEMP_FILE"

echo "Check completed."
