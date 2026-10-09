import os
import time
from serpapi import GoogleSearch
from dotenv import load_dotenv

load_dotenv()

SERPAPI_KEY = os.getenv("SERPAPI_KEY")

_PRICE_CACHE = {}
_CACHE_TTL = 300 # 5 minutes

def fetch_live_price(symbol: str, exchange: str = "NSE", force_refresh: bool = False) -> dict:
    if not SERPAPI_KEY or SERPAPI_KEY == "your_serpapi_api_key_here":
        return {"error": "Missing SERPAPI_KEY in environment"}

    cache_key = f"{symbol}:{exchange}"
    if not force_refresh and cache_key in _PRICE_CACHE:
        cache_entry = _PRICE_CACHE[cache_key]
        if time.time() - cache_entry['timestamp'] < _CACHE_TTL:
            return cache_entry['data']

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
            print(f"[SERPAPI ERROR] {symbol}: {results['error']}")
            return {"error": results["error"]}
            
        markets = results.get("summary")
        if not markets:
            print(f"[SERPAPI ERROR] {symbol}: No 'summary' field. Response keys: {list(results.keys())}")
            return {"error": "No 'summary' field in response"}
            
        # Prioritize extracted_price (numeric) over price (string)
        price = markets.get("extracted_price", markets.get("price"))
        
        # STRICT INSTRUMENT VALIDATION
        returned_stock = markets.get("stock", "").upper()
        returned_exchange = markets.get("exchange", "").upper()
        
        if exchange.upper() == "NSE" and returned_exchange and returned_exchange not in ["NSE", "BOM", "BSE", "NSI"]:
            return {"error": f"Invalid Exchange: Expected {exchange}, got {returned_exchange}"}
            
        if returned_stock and symbol.upper() not in returned_stock and returned_stock not in symbol.upper():
            return {"error": f"Invalid Instrument: Expected {symbol}, got {returned_stock}"}
        
        result = {
            "symbol": symbol,
            "exchange": exchange,
            "current_price": price,
            "currency": markets.get("currency"),
            "previous_close": markets.get("previous_close")
        }
        
        _PRICE_CACHE[cache_key] = {
            "timestamp": time.time(),
            "data": result
        }
        
        return result
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
