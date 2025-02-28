#!/bin/bash

# Define installation paths
INSTALL_DIR="/etc/ai_terminal"
SCRIPT_NAME="ai"
PYTHON_SCRIPT="$INSTALL_DIR/ai_command.py"
CONFIG_FILE="/etc/ai_terminal/ai.conf"
WRAPPER_SCRIPT="/usr/local/bin/$SCRIPT_NAME"
VENV_DIR="$INSTALL_DIR/venv"

# Ensure script is run with sudo for installation
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo for installation."
   exit 1
fi

# Ensure Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Installing..."
    apt update && apt install -y python3 python3-venv python3-pip
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Create Python virtual environment
python3 -m venv "$VENV_DIR"

# Install dependencies
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install requests

# Check if the config file does not exist
if [ ! -f "$CONFIG_FILE" ]; then
    # Create the config file with the specified content
    cat << EOF > "$CONFIG_FILE"
# AI Terminal Configuration
OPENAI_API_BASE_URL = 'https://api.openai.com/v1'
OPENAI_API_KEY = 'your-api-key-here'
MODEL_NAME = 'gpt-4o'
EOF

    echo "Config file created at $CONFIG_FILE"
else
    echo "Config file already exists at $CONFIG_FILE"
fi

# Set config permissions (readable by all users)
chmod 644 "$CONFIG_FILE"

# Create the Python script
cat << 'EOF' > "$PYTHON_SCRIPT"
#!/usr/bin/env python3

import os
import sys
import subprocess
import requests
import re
from pathlib import Path

CONFIG_PATHS = [
    Path.home() / ".ai_terminal.conf",  # User-specific config
    Path("/etc/ai_terminal/ai.conf")    # System-wide config
]

def load_config():
    """Load configuration from first available valid config file"""
    for config_path in CONFIG_PATHS:
        if config_path.exists():
            try:
                config = {}
                with open(config_path) as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#"):
                            key, value = line.split("=", 1)
                            config[key.strip()] = value.strip().strip("'\"")
                return config
            except Exception as e:
                print(f"Error loading config {config_path}: {str(e)}")
                sys.exit(1)
    
    print("No valid config file found. Check ~/.ai_terminal.conf or /etc/ai_terminal/ai.conf")
    sys.exit(1)

def sanitize_command(raw_command):
    """Remove markdown backticks and extra whitespace"""
    clean_command = re.sub(r'^`+|`+$', '', raw_command)  # Remove surrounding backticks
    clean_command = re.sub(r'^\$+\s*', '', clean_command)  # Remove leading $ signs
    return clean_command.strip()

def get_command(prompt, config):
    """Get command from OpenAI API"""
    headers = {
        "Authorization": f"Bearer {config['OPENAI_API_KEY']}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": config.get("MODEL_NAME", "gpt-4o"),
        "messages": [
            {"role": "system", "content": "You are a UNIX expert. Respond ONLY with the command, no explanation or formatting."},
            {"role": "user", "content": f"Convert to UNIX command: {prompt}"}
        ],
        "temperature": 0.1
    }
    
    try:
        response = requests.post(
            f"{config['OPENAI_API_BASE_URL']}/chat/completions",
            headers=headers,
            json=payload
        )
        response.raise_for_status()
        raw_command = response.json()["choices"][0]["message"]["content"].strip()
        return sanitize_command(raw_command)
    except Exception as e:
        print(f"API Error: {str(e)}")
        sys.exit(1)

def confirm_execution(command):
    """Prompt user for command confirmation"""
    print(f"\033[1mGenerated command:\033[0m\n{command}\n")
    while True:
        choice = input("\033[1mExecute this command? [y/N/e] \033[0m").strip().lower()
        if choice in ["y", "yes"]:
            return True, command
        elif choice in ["n", "no", ""]:
            print("Command canceled.")
            sys.exit(0)
        elif choice == "e":
            new_cmd = input("Enter edited command: ").strip()
            if new_cmd:
                return True, new_cmd
        print("Invalid choice. Please enter y/yes, n/no, or e/edit")

def main():
    if len(sys.argv) < 2:
        print("Usage: ai <natural language command>")
        print("Example: ai list all text files in current directory")
        sys.exit(1)
    
    user_query = " ".join(sys.argv[1:])
    config = load_config()
    
    print("\033[1mAnalyzing your request...\033[0m")
    command = get_command(user_query, config)
    
    execute, final_command = confirm_execution(command)
    if not execute:
        sys.exit(0)
    
    print(f"\033[1mExecuting:\033[0m {final_command}")
    try:
        # Check if sudo is needed
        if "sudo " in final_command and os.geteuid() != 0:
            print("\033[33mNote: This command requires elevated privileges\033[0m")
        
        subprocess.run(final_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"\033[31mCommand failed with error: {str(e)}\033[0m")
    except KeyboardInterrupt:
        print("\033[33mExecution canceled\033[0m")

if __name__ == "__main__":
    main()
EOF

# Set permissions
chmod +x "$PYTHON_SCRIPT"

# Create wrapper script
cat << EOF > "$WRAPPER_SCRIPT"
#!/bin/bash
source "$VENV_DIR/bin/activate"
python3 "$PYTHON_SCRIPT" "\$@"
EOF

chmod +x "$WRAPPER_SCRIPT"

# Post-install instructions
echo -e "\033[1mInstallation complete!\033[0m"
echo -e "Configure your API key in one of these locations:"
echo -e "1. System-wide: sudo nano $CONFIG_FILE"
echo -e "2. User-specific: nano ~/.ai_terminal.conf\n"
echo -e "Try it with:\n  ai list files sorted by size\n"