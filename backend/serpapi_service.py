import os
import json
import time
from serpapi import GoogleSearch
from dotenv import load_dotenv

load_dotenv()

_appdata = os.environ.get("APPDATA", os.path.join(os.path.expanduser("~"), "AppData", "Roaming"))
DATA_DIR = os.path.join(_appdata, "NijiLocal", "data")
os.makedirs(DATA_DIR, exist_ok=True)
CONFIG_PATH = os.path.join(DATA_DIR, ".serpapi_config")

def get_serpapi_config() -> dict:
    """Returns the raw configuration dict from the file, or None if it doesn't exist."""
    if os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, 'r') as f:
                return json.load(f)
        except Exception:
            pass
    return None

def get_serpapi_key() -> str:
    """Gets the active SerpApi key. UI-saved explicitly takes precedence."""
    config = get_serpapi_config()
    if config is not None:
        # If the file exists, it is the authoritative source, even if empty (cleared)
        return config.get("api_key", "")
    
    # Fallback to env ONLY if UI config has never been set/cleared
    return os.getenv("SERPAPI_KEY", "")

def get_active_config_source() -> str:
    """Returns the source of the active key: 'UI saved', 'environment', or 'None'"""
    config = get_serpapi_config()
    if config is not None:
        return "UI saved" if config.get("api_key") else "None (UI cleared)"
    
    env_key = os.getenv("SERPAPI_KEY", "")
    if env_key and env_key != "your_serpapi_api_key_here":
        return "environment"
        
    return "None"

def validate_and_save_key(api_key: str) -> dict:
    if not api_key or not api_key.strip():
        return {"success": False, "error": "API key cannot be empty"}
    
    clean_key = api_key.strip()
    
    # Validate with a lightweight query (e.g. MSFT price)
    params = {
        "engine": "google_finance",
        "q": "MSFT:NASDAQ",
        "api_key": clean_key
    }
    
    try:
        search = GoogleSearch(params)
        results = search.get_dict()
        
        if "error" in results:
            err = results["error"]
            if "Invalid API key" in err or "unauthorized" in err.lower():
                return {"success": False, "error": "Invalid API key"}
            elif "rate limit" in err.lower() or "quota" in err.lower():
                return {"success": False, "error": "API quota exceeded"}
            else:
                return {"success": False, "error": err}
        
        if "summary" not in results and "markets" not in results:
             return {"success": False, "error": "Invalid API response format"}
             
        # Save key
        os.makedirs(DATA_DIR, exist_ok=True)
        with open(CONFIG_PATH, 'w') as f:
            json.dump({"api_key": clean_key}, f)
            
        return {"success": True}
        
    except Exception as e:
        return {"success": False, "error": f"Network error or validation failed: {str(e)}"}

def clear_serpapi_key() -> bool:
    # Explicitly clear by saving an empty key, preventing fallback to environment
    os.makedirs(DATA_DIR, exist_ok=True)
    try:
        with open(CONFIG_PATH, 'w') as f:
            json.dump({"api_key": ""}, f)
        return True
    except Exception:
        return False

def get_serpapi_status() -> dict:
    key = get_serpapi_key()
    source = get_active_config_source()
    is_configured = bool(key and key != "your_serpapi_api_key_here")
    
    # Run a quick validation on the active key for diagnostic purposes
    validation_result = "Valid" if is_configured else "Not Validated"
    if is_configured:
        params = {"engine": "google_finance", "q": "MSFT:NASDAQ", "api_key": key}
        try:
            test_search = GoogleSearch(params)
            test_results = test_search.get_dict()
            if "error" in test_results:
                validation_result = f"Error: {test_results['error']}"
        except Exception as e:
             validation_result = f"Failed to test: {str(e)}"
    
    return {
        "status": "Connected" if is_configured else "Not Configured",
        "diagnostic": {
            "source": source,
            "has_key": is_configured,
            "validation": validation_result
        }
    }

_PRICE_CACHE = {}
_CACHE_TTL = 300 # 5 minutes

def fetch_live_price(symbol: str, exchange: str = "NSE", force_refresh: bool = False) -> dict:
    key = get_serpapi_key()
    if not key or key == "your_serpapi_api_key_here":
        return {"error": "Missing SERPAPI_KEY. Configure it in the app."}

    cache_key = f"{symbol}:{exchange}"
    if not force_refresh and cache_key in _PRICE_CACHE:
        cache_entry = _PRICE_CACHE[cache_key]
        if time.time() - cache_entry['timestamp'] < _CACHE_TTL:
            return cache_entry['data']

    params = {
        "engine": "google_finance",
        "q": f"{symbol}:{exchange}",
        "api_key": key
    }
    
    try:
        search = GoogleSearch(params)
        results = search.get_dict()
        
        if "error" in results:
            print(f"[SERPAPI ERROR] {symbol}: {results['error']}")
            return {"error": results["error"]}
            
        markets = results.get("summary")
        if not markets:
            print(f"[SERPAPI ERROR] {symbol}: No 'summary' field. Response keys: {list(results.keys())}")
            return {"error": "No 'summary' field in response"}
            
        price = markets.get("extracted_price", markets.get("price"))
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
    key = get_serpapi_key()
    if not key or key == "your_serpapi_api_key_here":
        return [{"error": "Missing SERPAPI_KEY. Configure it in the app."}]

    params = {
        "engine": "google_news",
        "q": f"{symbol} stock news",
        "tbs": "qdr:d",
        "gl": "in",
        "api_key": key
    }
    
    try:
        search = GoogleSearch(params)
        results = search.get_dict()
        
        if "error" in results:
            return [{"error": results["error"]}]
            
        news_results = results.get("news_results", [])
        
        clean_news = []
        for item in news_results[:5]:
            clean_news.append({
                "title": item.get("title"),
                "source": item.get("source", {}).get("name", "Unknown Source"),
                "date": item.get("date"),
                "link": item.get("link")
            })
            
        return clean_news
    except Exception as e:
        return [{"error": f"Failed to fetch news for {symbol}: {str(e)}"}]
