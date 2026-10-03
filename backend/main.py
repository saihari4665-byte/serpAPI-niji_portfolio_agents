from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pandas as pd
import io
import os
import math

from serpapi_service import fetch_live_price, fetch_top_news
from analyzer import calculate_portfolio_weights, analyze_portfolio_risk

def sanitize_floats(obj):
    """Recursively replace NaN/Infinity float values with None so JSON serialization never fails."""
    if isinstance(obj, float):
        if math.isnan(obj) or math.isinf(obj):
            return None
        return obj
    if isinstance(obj, dict):
        return {k: sanitize_floats(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [sanitize_floats(v) for v in obj]
    return obj

app = FastAPI(title="Niji Portfolio Agent API")

# Enable CORS for local clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ScanResponse(BaseModel):
    portfolio_summary: dict
    market_data: dict

# Define paths to safely save and read the latest upload
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
LATEST_PORTFOLIO_PATH = os.path.join(DATA_DIR, "latest_portfolio.csv")
DUMMY_PATH = os.path.join(DATA_DIR, "dummy_portfolio.csv")

def get_current_dataframe():
    """Helper to load the most recently uploaded file, or fallback to dummy if none exists."""
    if os.path.exists(LATEST_PORTFOLIO_PATH):
        return pd.read_csv(LATEST_PORTFOLIO_PATH)
    elif os.path.exists(DUMMY_PATH):
        return pd.read_csv(DUMMY_PATH)
    else:
        raise HTTPException(status_code=404, detail="No portfolio data found.")

@app.post("/api/portfolio/upload")
async def upload_portfolio(file: UploadFile = File(None)):
    """
    Accepts a CSV upload, SAVES IT for subsequent requests, and returns weights.
    """
    if file:
        content = await file.read()
        
        # Save the file temporarily so /scan and /analyze can use it!
        os.makedirs(DATA_DIR, exist_ok=True)
        with open(LATEST_PORTFOLIO_PATH, "wb") as f:
            f.write(content)
            
        df = pd.read_csv(io.BytesIO(content))
    else:
        df = get_current_dataframe()
    
    weights = calculate_portfolio_weights(df)
    return sanitize_floats({"message": "Portfolio loaded successfully", "data": weights})

@app.post("/api/portfolio/scan", response_model=ScanResponse)
async def scan_portfolio(file: UploadFile = File(None)):
    """
    Sanitizes tickers, calls SerpApi, returns live market feed.
    """
    if file:
        content = await file.read()
        df = pd.read_csv(io.BytesIO(content))
    else:
        # Load the saved Kite CSV instead of the dummy!
        df = get_current_dataframe()
    
    weights = calculate_portfolio_weights(df)
    tickers = list(weights["holdings"].keys())
    
    market_data = {}
    
    for ticker in tickers:
        market_data[ticker] = {
            "price": fetch_live_price(ticker),
            "news": fetch_top_news(ticker)
        }
        
    return sanitize_floats({"portfolio_summary": weights, "market_data": market_data})

@app.post("/api/portfolio/analyze")
async def analyze_portfolio(file: UploadFile = File(None)):
    """
    Passes sanitized context to local LLM, returns structured markdown risk assessment.
    """
    # 1. Get the data
    if file:
        content = await file.read()
        df = pd.read_csv(io.BytesIO(content))
    else:
        # Load the saved Kite CSV instead of the dummy!
        df = get_current_dataframe()
        
    weights = calculate_portfolio_weights(df)
    
    # 2. Get market data
    tickers = list(weights["holdings"].keys())
    market_data = {}
    for ticker in tickers:
        market_data[ticker] = {
            "price": fetch_live_price(ticker),
            "news": fetch_top_news(ticker)
        }
        
    # 3. Analyze Risk
    analysis_markdown = analyze_portfolio_risk(weights, market_data)
    
    return sanitize_floats({"analysis": analysis_markdown})

@app.get("/")
def read_root():
    return {"message": "Niji Portfolio Agent API is running."}