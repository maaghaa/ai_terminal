# AI Terminal - Natural Language to UNIX Commands

AI Terminal is a command-line tool that converts natural language instructions into UNIX commands using OpenAI's GPT models. It's designed to help users quickly generate and execute terminal commands without needing to remember complex syntax.

---

## How to Install

You can install AI Terminal directly using `wget`:

1. **Download and run the installation script**:
   ```bash
   wget https://raw.githubusercontent.com/maaghaa/ai_terminal/main/install_ai.sh
   sudo bash install_ai.sh
   ```

2. **Configure your OpenAI API key**:
   - For system-wide configuration (requires `sudo`):
     ```bash
     sudo nano /etc/ai_terminal/ai.conf
     ```
   - For user-specific configuration:
     ```bash
     nano ~/.ai_terminal.conf
     ```

   Set your API key in the configuration file:
   ```ini
   OPENAI_API_KEY = 'your-api-key-here'
   ```

3. **Verify the installation**:
   Try running the tool with a simple command:
   ```bash
   ai list files in the current directory
   ```

---

## Usage

Basic syntax:
```bash
ai <natural language command>
```

Examples:
```bash
ai list all text files in current directory
ai show running processes sorted by memory usage
ai find all files larger than 100MB in /var/log
```

The tool will:
1. Analyze your request
2. Generate the appropriate UNIX command
3. Prompt for confirmation before execution

---

## Configuration Options

The configuration file supports the following settings:

```ini
OPENAI_API_BASE_URL = 'https://api.openai.com/v1'  # API endpoint
OPENAI_API_KEY = 'your-api-key-here'              # Your OpenAI API key
MODEL_NAME = 'gpt-4o'                             # GPT model to use
```

---

## Files and Locations

- Installation directory: `/etc/ai_terminal/`
- Python script: `/etc/ai_terminal/ai_command.py`
- System-wide config: `/etc/ai_terminal/ai.conf`
- User-specific config: `~/.ai_terminal.conf`
- Virtual environment: `/etc/ai_terminal/venv/`
- Wrapper script: `/usr/local/bin/ai`

---

## Safety Features

- Always prompts for confirmation before executing commands
- Highlights commands requiring sudo privileges
- Allows command editing before execution
- Sanitizes markdown and shell prompt characters
- Runs in isolated Python virtual environment

---

## Contributing

Contributions are welcome! Please open an issue or pull request for any bugs or feature requests.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Disclaimer

This tool uses AI-generated commands. Always review the generated commands before execution, especially for operations that could affect system stability or security. The authors are not responsible for any damage caused by improper use of this tool.

---

For more details, visit the repository: [https://github.com/maaghaa/ai_terminal](https://github.com/maaghaa/ai_terminal)