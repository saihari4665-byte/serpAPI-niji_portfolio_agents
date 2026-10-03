import os
from serpapi import GoogleSearch
from dotenv import load_dotenv

load_dotenv()

SERPAPI_KEY = os.getenv("SERPAPI_KEY")

def fetch_live_price(symbol: str, exchange: str = "NSE") -> dict:
    if not SERPAPI_KEY or SERPAPI_KEY == "your_serpapi_api_key_here":
        return {"error": "Missing SERPAPI_KEY in environment"}

    params = {
        "engine": "google_finance",
        "q": f"{symbol}:{exchange}",
        "api_key": SERPAPI_KEY
    }
    
    try:
        search = GoogleSearch(params)
        results = search.get_dict()
        
        # Check if the search was successful
        if "error" in results:
            return {"error": results["error"]}
            
        markets = results.get("summary", {})
        price = markets.get("price")
        
        return {
            "symbol": symbol,
            "exchange": exchange,
            "current_price": price,
            "currency": markets.get("currency"),
            "previous_close": markets.get("previous_close")
        }
    except Exception as e:
        return {"error": f"Failed to fetch price for {symbol}: {str(e)}"}

def fetch_top_news(symbol: str) -> list:
    if not SERPAPI_KEY or SERPAPI_KEY == "your_serpapi_api_key_here":
        return [{"error": "Missing SERPAPI_KEY in environment"}]

    params = {
        "engine": "google_news",
        "q": f"{symbol} stock news",
        "tbs": "qdr:d",
        "gl": "in",
        "api_key": SERPAPI_KEY
    }
    
    try:
        search = GoogleSearch(params)
        results = search.get_dict()
        
        if "error" in results:
            return [{"error": results["error"]}]
            
        news_results = results.get("news_results", [])
        
        # Extract just the essential parts to keep the payload clean
        clean_news = []
        for item in news_results[:5]: # Get top 5
            clean_news.append({
                "title": item.get("title"),
                "source": item.get("source", {}).get("name", "Unknown Source"),
                "date": item.get("date"),
                "link": item.get("link")
            })
            
        return clean_news
    except Exception as e:
        return [{"error": f"Failed to fetch news for {symbol}: {str(e)}"}]
