# Toolhelper

## Purpose

`toolhelper` is a lightweight command-line utility for Windows PowerShell and Command Prompt. It provides a quick reference to commands for commonly used developer tools based on metadata keywords. Users can query the tool using a keyword or phrase, and `toolhelper` will return matching command snippets based on a fuzzy match. It also allows users to update the tool-command mappings interactively.

## Features

* Keyword-based lookup of tool commands
* Fuzzy matching for flexibility in search
* Add new tools, metadata, and commands dynamically
* Simple and extensible JSON-based config (`toolmap.json`)

## Setup on Windows

### 1. Prerequisites

* PowerShell (recommended PowerShell 5.1+)

### 2. Clone the Repository

```bash
cd <your-folder>
git clone https://github.com/amits781/toolhelper.git
cd toolhelper
```

### 3. Make Sure the Following Files Are Present

* `toolhelper.ps1` – main PowerShell script
* `toolhelper.bat` – batch wrapper to allow execution via CMD or PowerShell
* `toolmap.json` – (Optional) stores metadata and command mappings. If not present, script will create one once the new tool is added.

### 4. Add `toolhelper` to System PATH

Add the directory containing `toolhelper.bat` to the Windows system `PATH`:

1. Press `Win + R`, type `sysdm.cpl`, press Enter
2. Go to the **Advanced** tab → **Environment Variables**
3. Under **System variables**, find and edit the `Path` variable
4. Add the full path of your `toolhelper` directory
5. Restart Command Prompt or PowerShell for changes to take effect

You can now run `toolhelper` from any directory in your terminal.

## Usage

### Querying with a Keyword

```bash
toolhelper -q <keyword>
```

Examples:

```bash
toolhelper -q docker
toolhelper -q kubectl
```

### Adding a New Tool, Metadata, or Command

```bash
toolhelper -t <toolname> [-m <metadata>] [-c <command>]
```

Examples:

```bash
toolhelper -t kubectl -m "deploy" -c "kubectl apply -f deployment.yaml"
toolhelper -t git -m push -c "git push origin main"
toolhelper -t docker -c "docker compose up -d"
```

### Notes

* Quoted strings are recommended when metadata or commands contain spaces
* JSON file is updated automatically after each addition

## Example `toolmap.json`

```json
{
  "metadata": {
    "git": ["code", "push", "clone"],
    "docker": ["container", "compose", "image"],
    "kubectl": ["deploy", "pod", "service"]
  },
  "commands": {
    "git": ["git push", "git clone <repo-url>"],
    "docker": ["docker compose up -d", "docker build -t myapp ."],
    "kubectl": ["kubectl apply -f deployment.yaml", "kubectl get pods"]
  }
}
```

## Output

```powershell
PS C:\Users\username> toolhelper -q push

Matched Tool: git
------------------
git push origin main
```

---

## Author

Developed and maintained by Amit Kumar Sharma.

Feel free to fork, modify, and contribute to this project!
