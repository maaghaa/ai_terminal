# AI Command Executor for Ubuntu

This project allows you to run natural language commands in your terminal and have them converted into Unix commands using an AI model (OpenAI's GPT). Simply type:

```bash
ais count files in the folder
```

And the script will:
1. Prompt the AI to convert the natural language command into a Unix command.
2. Display the generated command.
3. Execute the command.

## Installation

Run the following commands to install the script:

```bash
chmod +x install_ai.sh && sudo ./install_ai.sh
```

## Configuration

The script uses a configuration file stored at `/etc/ai_command.conf`. After installation, you need to edit this file to provide your API details:

```bash
sudo nano /etc/ai_command.conf
```

Modify the following variables:

```bash
OPENAI_API_BASE_URL='https://api.openai.com/v1'
OPENAI_API_KEY='your-api-key'
OPENAI_MODEL_NAME='gpt-4-turbo'
```

Save and exit the file (`CTRL+X`, then `Y`, then `ENTER`).

## Usage

To use the command, simply type:

```bash
ai <natural language command>
```

For example:

```bash
ai count files in the folder
```

Example output:

```
Prompting AI...
Executing: ls | wc -l
23
```

## How It Works

1. Reads the configuration from `/etc/ai_command.conf`.
2. Sends the input command to the OpenAI API for conversion.
3. Displays the generated Unix command.
4. Executes the command in the terminal.

## Uninstallation

To remove the installed files, run:

```bash
sudo rm /usr/local/bin/ai /usr/local/bin/ai_command.py /etc/ai_command.conf
```

## Troubleshooting

- **API Key Not Set:** Ensure that `OPENAI_API_KEY` is correctly set in `/etc/ai_command.conf`.
- **Permission Issues:** If you get permission errors, try running the script with `sudo`.
- **AI Not Responding:** Check your `OPENAI_API_BASE_URL` and ensure your API key is valid.

## Contributing

Feel free to open issues or submit pull requests to improve this project.

## License

This project is open-source and licensed under the MIT License.

