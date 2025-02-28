#!/bin/bash

# Define installation paths
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="ai"
PYTHON_SCRIPT="$INSTALL_DIR/ai_command.py"
CONFIG_FILE="/etc/ai_command.conf"

# Create the config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating config file at $CONFIG_FILE..."
    sudo bash -c "cat << EOF > $CONFIG_FILE
OPENAI_API_BASE_URL='https://api.openai.com/v1'
OPENAI_API_KEY='your-api-key'
OPENAI_MODEL_NAME='gpt-4-turbo'
EOF"
fi

# Create the Python script
sudo bash -c "cat << 'EOF' > $PYTHON_SCRIPT
#!/usr/bin/env python3

import os
import sys
import subprocess

# Load config file
config_path = "/etc/ai_command.conf"
if os.path.exists(config_path):
    with open(config_path) as f:
        for line in f:
            key, _, value = line.strip().partition("=")
            if key and value:
                os.environ[key] = value.strip(\"'\")  # Remove quotes if present

# Get environment variables
api_base = os.getenv("OPENAI_API_BASE_URL")
api_key = os.getenv("OPENAI_API_KEY")
model_name = os.getenv("OPENAI_MODEL_NAME", "gpt-4o")

if not api_base or not api_key:
    print("Error: Please configure OPENAI_API_BASE_URL and OPENAI_API_KEY in /etc/ai_command.conf")
    sys.exit(1)

# Get user input
user_command = " ".join(sys.argv[1:])
if not user_command:
    print("Usage: ai <natural language command>")
    sys.exit(1)

print("Prompting AI...")

# Call OpenAI API
import openai
openai.api_key = api_key
openai.api_base = api_base

response = openai.ChatCompletion.create(
    model=model_name,
    messages=[
        {"role": "system", "content": "You are an assistant that converts natural language into Unix commands."},
        {"role": "user", "content": f"Convert this to a Unix command: {user_command}"}
    ]
)

# Extract command
command = response["choices"][0]["message"]["content"].strip()

print(f"Executing: {command}")

# Run the command
subprocess.run(command, shell=True)
EOF"

# Make the Python script executable
sudo chmod +x "$PYTHON_SCRIPT"

# Create the Bash wrapper script
sudo bash -c "cat << EOF > $INSTALL_DIR/$SCRIPT_NAME
#!/bin/bash
python3 $PYTHON_SCRIPT \"\$@\"
EOF"

# Make the wrapper script executable
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "Installation complete!"
echo "Config file created at $CONFIG_FILE"
echo "Modify the config file to update API settings."
echo "Usage: ai <natural language command>"
