# Niji LOCAL — Privacy-First Portfolio Intelligence

A privacy-first Windows desktop application for Indian stock portfolio analysis, developed for the **SerpApi India Hackathon 2026**.

Niji LOCAL combines a Flutter desktop frontend, a FastAPI backend, local AI analysis, and SerpApi-powered public market research to help users understand portfolio performance, identify potential risks, and explore relevant market information.

---
## 🧑‍⚖️ For Hackathon Judges — Try Niji LOCAL

Thank you for evaluating **Niji LOCAL**, our privacy-first AI-powered portfolio intelligence desktop application built for Indian stock market investors.

### 📥 Download and Install

**[Download Niji LOCAL v1 for Windows](https://github.com/saiharish4665-byte/serpAPI-niji_portfolio_agents/releases/tag/v1)**

1. Open the release page above.
2. Download `NijiLocal_Setup.exe`.
3. Run the installer and follow the installation instructions.

### ⚙️ Requirements

- **Operating system:** Windows 10/11 (64-bit).
- **Local AI:** Install [Ollama](https://ollama.com/) and run `ollama pull gemma2:2b` to download the Gemma 2 2B model.
- **Live market data:** Configure a valid [SerpApi API key](https://serpapi.com/) in the application.

### 🔍 What to Explore

- Portfolio dashboard and investment performance.
- Live market-price updates.
- AI-powered portfolio analysis and risk insights.
- Sector allocation and portfolio concentration.
- Investor intelligence reports powered by local AI.

### 🔐 Privacy

Niji LOCAL is designed to keep sensitive portfolio information on your device while using local AI for analysis. SerpApi is used to retrieve public market information. Please use a sample portfolio when evaluating the application.

**Thank you for your time and consideration!** We welcome your feedback.

## 1. System Requirements

### For users installing Niji LOCAL

- **Operating system:** Windows 10 or Windows 11, 64-bit.
- **Internet connection:** Required for online market research and SerpApi requests.
- **SerpApi API key:** Required for features that retrieve market information through SerpApi.
- **Ollama:** Required for local AI analysis if it is not bundled or automatically installed by the application.
- **Storage:** Sufficient free space for the application and any separately installed AI models.

**Note:** Python, Flutter, and Inno Setup are development tools and should not be required for ordinary users if the packaged application contains all its necessary components.

### For developers

- Git
- Flutter SDK
- Windows desktop build tools required by Flutter
- Python compatible with the backend dependencies
- pip for installing Python packages
- Ollama and the configured model, if using local AI
- Inno Setup 6, if rebuilding the Windows installer

---

## 2. Installation on Windows

### Step 1: Obtain the installer

Download `NijiLocal_Setup.exe` from the project's trusted release or distribution location.

### Step 2: Install the application

1. Double-click `NijiLocal_Setup.exe`.
2. Follow the installation wizard.
3. Complete the installation.
4. Launch **Niji LOCAL** from the desktop shortcut or Start menu, if provided.

### Step 3: Configure the application

- Configure your SerpApi API key through the application's supported settings.
- Ensure Ollama and the required model are available if local AI analysis requires them.
- Connect to the internet for online market-data and research features.

### Step 4: Import a portfolio

1. Open Niji LOCAL.
2. Import a supported portfolio CSV file.
3. Review your holdings and portfolio values.
4. Refresh market prices if the feature is available.
5. Explore the dashboard, reports, and portfolio intelligence features.

**Important:** The exact first-run configuration depends on the packaged application's implementation. Refer to the application's settings and troubleshooting sections if a service is unavailable.

---

## 3. Features

### Portfolio Dashboard

- View portfolio holdings and key portfolio metrics.
- Review invested value, current market value, and profit or loss.
- Understand the distribution of holdings and sector exposure, where supported.

### CSV Portfolio Import

- Import portfolio information from supported CSV files.
- Process portfolio data through the backend.
- Review imported holdings and portfolio information.

### Market Research with SerpApi

- Retrieve public market information through SerpApi.
- Support market-price lookups and relevant research where implemented.
- Display market-data availability and connection status.

### Local AI Portfolio Intelligence

- Use a locally configured AI model for portfolio reasoning.
- Generate portfolio insights and explanations when the AI service is available.
- Help identify potential concentration concerns, risks, and research priorities.

### Reports and Analysis

- Review portfolio performance and AI-generated assessments.
- Explore potential strengths, weaknesses, and risk factors where supported.
- Use the available reports to guide further research.

*Feature availability depends on the current implementation, configuration, and external service availability.*

---

## 4. Technology Stack

| Component | Technology |
|---|---|
| Desktop frontend | Flutter and Dart |
| Backend API | Python and FastAPI |
| Local AI inference | Ollama with the configured model |
| Public market research | SerpApi |
| Portfolio data | CSV and local persistence, where implemented |
| Windows backend packaging | PyInstaller |
| Windows installer | Inno Setup |

---

## 5. Architecture

Niji LOCAL separates the desktop interface, backend processing, local AI, and public market research.

1. **Flutter frontend:** Provides the desktop interface for importing portfolios, viewing metrics, and accessing analysis features.
2. **FastAPI backend:** Handles API requests, portfolio processing, and communication with configured services.
3. **Local AI:** Performs AI reasoning locally when Ollama is configured and available.
4. **SerpApi integration:** Retrieves public market information needed for research and price lookups.
5. **Local data processing:** Processes portfolio information and calculates financial metrics within the application.

### Data flow

```text
User
  |
  v
Flutter Desktop Application
  |
  v
FastAPI Backend
  |
  +----> Local Portfolio Processing
  |
  +----> Local AI (Ollama)
  |
  +----> SerpApi
           |
           v
     Public Market Information
  |
  v
Portfolio Insights and Reports
```

The diagram represents the intended architecture; exact processing paths depend on the implemented endpoints and services.

---

## 6. Configuration

### SerpApi

SerpApi is used to retrieve public information from supported search and market-data services.

1. Obtain your own API key from SerpApi.
2. Configure the key using the application's supported settings or configuration mechanism.
3. Check the connection status in the application.
4. Verify internet connectivity if requests fail.

Keep API keys private. Never commit real credentials to GitHub.

### Ollama

Local AI features require a working Ollama installation and the model configured by the application, unless these components are provided through another supported installation mechanism.

1. Install and start Ollama if required.
2. Ensure the configured model is available locally.
3. Check the backend logs if AI analysis fails.

Use the model name and setup instructions defined by the actual project configuration.

---

## 7. Privacy and Security

Niji LOCAL is designed around local-first portfolio analysis.

- Private portfolio information should remain local.
- Quantities, purchase prices, invested values, personal financial calculations, and portfolio totals must not be sent to SerpApi.
- External market-research requests should contain only the public information necessary for the requested lookup.
- API keys and credentials must remain outside frontend source code and version control.
- Local configuration files and private portfolio CSV files should not be committed to the repository.
- AI-generated explanations should be treated as informational analysis, not guaranteed predictions.

Users should review the implementation and configuration before processing sensitive financial information.

---

## 8. Build from Source

This section is intended for developers who want to modify or rebuild Niji LOCAL.

### Step 1: Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd serp_api_proj
```

Replace the placeholder with the actual public repository URL.

### Step 2: Set up the Python backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

If PowerShell blocks virtual-environment activation, use the appropriate Python executable and pip commands for your environment.

### Step 3: Configure backend settings

Review the backend configuration and environment-variable requirements before running the server. Use a local environment file or the application's supported configuration mechanism for secrets.

Do not commit `.env` files or real API keys.

### Step 4: Run the backend during development

If the backend entry point is `main.py` and the FastAPI application object is named `app`, the development command is:

```powershell
uvicorn main:app --reload
```

Run the command from the backend directory. Confirm the actual application entry point before using it.

### Step 5: Build the Flutter frontend

Open another terminal:

```powershell
cd frontend
flutter pub get
flutter build windows --release
```

The Windows release executable is typically generated under:

```text
frontend/build/windows/x64/runner/Release/
```

### Step 6: Package the backend

The backend packaging process uses the project's PyInstaller configuration and launcher scripts.

Review `backend.spec`, `launcher.spec`, and `launcher.py` to determine the correct build command and required dependencies. Ensure that the packaged backend starts successfully before creating a new installer.

### Step 7: Build the Windows installer

Open `setup.iss` with Inno Setup Compiler after confirming that the frontend and backend build artifacts are present at the paths expected by the installer script.

Compile the installer and test it on a Windows environment separate from the development setup when possible.

---

## 9. Project Structure

```text
serp_api_proj/
├── backend/
│   ├── main.py
│   ├── analyzer.py
│   ├── serpapi_service.py
│   ├── requirements.txt
│   └── run_server.py
├── frontend/
│   ├── lib/
│   ├── test/
│   ├── windows/
│   ├── pubspec.yaml
│   └── README.md
├── data/
├── installer/
├── launcher.py
├── launcher.spec
├── backend.spec
├── setup.iss
├── .gitignore
└── README.md
```

This is a high-level overview. Actual files may differ depending on the current branch and packaging configuration.

---

## 10. Troubleshooting

### The application does not start

- Restart the application.
- Check the installed application files and backend logs, if available.
- Verify that the installer includes the required packaged components.
- Rebuild and test the installer if the issue occurs only in packaged installations.

### SerpApi is disconnected

- Verify that your API key is configured correctly.
- Check your internet connection.
- Check the API usage limits and error messages.
- Confirm that the backend can reach the configured SerpApi endpoint.

### Market prices do not update

- Verify the SerpApi connection.
- Check whether the selected instrument can be resolved by the market-data lookup.
- Review backend logs for failed requests.
- Remember that prices may be delayed or unavailable outside supported market-data conditions.

### AI analysis is unavailable

- Confirm that Ollama is running if required.
- Ensure the configured model is installed and available.
- Review backend logs for connection or model errors.

### CSV import fails

- Confirm that the file is a supported CSV format.
- Check that the file contains the expected column headers and valid data.
- Review any import error messages before retrying.

---

## 11. Disclaimer

Niji LOCAL provides informational portfolio analysis and educational insights. It does not guarantee investment returns or provide a substitute for professional financial advice.

Market information may be delayed, incomplete, or inaccurate. Verify important information independently before making investment decisions.

---

## 12. License

No open-source license has been specified for this repository yet. Unless a license is added, the project remains under its default copyright protections. Do not assume that others have permission to redistribute or modify it.
