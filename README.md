# Niji Portfolio Agent

A privacy-first desktop application built for the SerpApi India Hackathon 2026. 
It analyzes your Indian stock portfolio locally by querying SerpApi for market data and using a local LLM to assess risk, ensuring your sensitive financial data remains private.

## Getting Started

1. Set up a Python virtual environment and install dependencies:
   ```bash
   cd backend
   python -m venv .venv
   # On Windows:
   .venv\Scripts\activate
   # On macOS/Linux:
   source .venv/bin/activate
   
   pip install -r requirements.txt
   ```

2. Copy `.env.example` to `.env` and configure your API keys:
   ```bash
   cp .env.example .env
   ```
   Add your SerpApi Key.

3. Run the FastAPI server:
   ```bash
   uvicorn main:app --reload
   ```
