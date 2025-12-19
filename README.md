# Invoke-Gemini 🤖

[![PowerShell Core](https://img.shields.io/badge/PowerShell-%3E%3D7.0-blue.svg)](https://microsoft.com/powershell)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A robust, pipeline-aware PowerShell wrapper for Google's Gemini LLM API. Seamlessly integrate generative AI into your terminal workflows, automation scripts, or enjoy a full interactive chat experience directly from the CLI.

---

## ✨ Features

* **Pipeline Ready:** Pipe text directly into the model and pipe the response into files or other commands.
* **Interactive Mode:** A persistent chat session that remembers conversation history.
* **Flexible Config:** Manage API keys and model preferences via a `config.json` file or environment variables.
* **Dev-Friendly:** Full support for `-Verbose`, `-ErrorAction`, and standard PowerShell parameter sets.
* **Modern Models:** Supports `gemini-2.5-flash`, `gemini-2.5-pro`, and newer.

---

## 🚀 Quick Start

### 1. Installation
Clone this repository or download the `Invoke-Gemini.ps1` script to your local machine.

```powershell
git clone https://github.com/MikeC-I/Invoke-Gemini.git
cd Invoke-Gemini
```

### 2. Configuration
Create a `config.json` file in the same directory as the script to store your credentials:

```json
{
    "ApiKey": "YOUR_GOOGLE_AI_STUDIO_KEY",
    "Model": "gemini-2.5-flash"
}
```
*Alternatively, set a system environment variable:* `$env:GEMINI_API_KEY = "your_key"`.

### 3. Usage

**Pipeline usage (Automation):**
```powershell
"Convert this CSV data to JSON: Name, Age `n John, 30" | .\Invoke-Gemini.ps1 | Out-File data.json
```

**Direct Command:**
```powershell
$response = .\Invoke-Gemini.ps1 -Prompt "What are the top 3 features of PowerShell 7?"
```

**Interactive Chat:**
```powershell
.\Invoke-Gemini.ps1 -Interactive
```

---

## 🛠 Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `-Prompt` | `String` | The text input for the AI. Supports Pipeline input. |
| `-Interactive` | `Switch` | Starts a stateful chat session in the console. |
| `-ConfigPath` | `String` | Custom path to your JSON config (Defaults to script folder). |
| `-ApiKey` | `String` | Manually provide API key (Overrides config/env). |
| `-Model` | `String` | Specify model (e.g., `gemini-2.5-pro`). |


---

## 🔧 Troubleshooting

* **Unauthorized (401):** Ensure your API key is correct in `config.json` or your environment variables.
* **Model Not Found:** Ensure the model string matches the [Google AI Studio](https://aistudio.google.com/) model naming conventions.
* **Execution Policy:** If the script won't run, try: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process`.

---

### License
Distributed under the MIT License. See `LICENSE` for more information.
