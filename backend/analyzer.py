import os
import pandas as pd
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

def calculate_portfolio_weights(df: pd.DataFrame) -> dict:
    # 1. Clean headers and globally scrub all empty cells/NaNs
    df.columns = df.columns.str.strip()
    df = df.fillna(0.0)
    
    # Auto-map Zerodha Kite headers
    if "Instrument" in df.columns:
        df.rename(columns={"Instrument": "Symbol"}, inplace=True)
    if "Cur. val" in df.columns:
        df.rename(columns={"Cur. val": "Investment Value"}, inplace=True)

    # 2. Safely calculate Investment Value with coercion
    if "Investment Value" in df.columns:
        df["Investment Value"] = pd.to_numeric(df["Investment Value"], errors="coerce").fillna(0.0)
    elif "Quantity" in df.columns and "Avg Buy Price" in df.columns:
        df["Investment Value"] = pd.to_numeric(df["Quantity"], errors="coerce").fillna(0.0) * pd.to_numeric(df["Avg Buy Price"], errors="coerce").fillna(0.0)
    elif "Quantity" in df.columns and "Price" in df.columns:
        df["Investment Value"] = pd.to_numeric(df["Quantity"], errors="coerce").fillna(0.0) * pd.to_numeric(df["Price"], errors="coerce").fillna(0.0)
    else:
        num_cols = df.select_dtypes(include=["number"]).columns
        df["Investment Value"] = pd.to_numeric(df[num_cols[-1]], errors="coerce").fillna(0.0) if len(num_cols) > 0 else 1.0

    total = df["Investment Value"].sum()
    if pd.isna(total) or total == 0:
        total = 1.0

    symbol_col = "Symbol" if "Symbol" in df.columns else df.columns[0]

    holdings = {}
    for _, row in df.iterrows():
        sym = str(row[symbol_col]).strip()
        val = float(row["Investment Value"])
        
        # Final safety check against NaN creeping in
        if pd.isna(val):
            val = 0.0
            
        holdings[sym] = {
            "weight_percent": round((val / total) * 100, 2),
            "investment_value": val
        }

    return {
        "total_investment": float(total),
        "holdings": holdings
    }

def analyze_portfolio_risk(weights: dict, market_data: dict) -> str:
    prompt = (
        "You are an expert AI financial analyst. Assess the risk of the following stock portfolio "
        "based on its weight distribution and current market conditions.\n\n"
    )

    prompt += "### Portfolio Composition (by weight only):\n"
    holdings_dict = weights.get("holdings", weights)
    for symbol, data in holdings_dict.items():
        if isinstance(data, dict):
            pct = data.get("weight_percent", data.get("weight_pct", "N/A"))
            prompt += f"- {symbol}: {pct}%\n"

    prompt += "\n### Current Market Data & News:\n"
    for symbol, m_data in market_data.items():
        prompt += f"**{symbol}**:\n"
        price_info = m_data.get("price", {}) if isinstance(m_data, dict) else {}
        prompt += f"- Current Price: {price_info.get('current_price', 'N/A')} {price_info.get('currency', '')}\n"

        news = m_data.get("news", []) if isinstance(m_data, dict) else []
        if news and isinstance(news, list) and len(news) > 0 and "error" not in news[0]:
            prompt += "- Recent Headlines:\n"
            for item in news[:3]:
                prompt += f"  * {item.get('title', '')} ({item.get('source', '')})\n"

    prompt += "\n### Analysis Request:\n"
    prompt += "1. What are the key systemic and stock-specific risks in this portfolio?\n"
    prompt += "2. How might recent news impact these holdings in the short term?\n"
    prompt += "3. Are there concentration risks, and what diversification strategies would you recommend?\n\n"
    prompt += "Format your response in Markdown with clear headings and bullet points."

    return call_local_llm(prompt)

def call_local_llm(prompt: str) -> str:
    base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434/v1")
    model_name = os.getenv("LOCAL_MODEL_NAME", "gemma2:2b")

    try:
        client = OpenAI(
            base_url=base_url,
            api_key="ollama"
        )

        response = client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": "You are a helpful financial assistant. Respond with markdown."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=1500
        )

        return response.choices[0].message.content
    except Exception as e:
        return f"Error connecting to local LLM ({model_name} at {base_url}):\n\n{str(e)}\n\nMake sure Ollama is running and the model is pulled."