import sys
import json
from serpapi_service import fetch_live_price, fetch_top_news

def main():
    ticker = "TATAMOTORS"
    if len(sys.argv) > 1:
        ticker = sys.argv[1]
        
    print(f"Testing SerpApi connection for {ticker}...")
    
    print("\n--- Live Price Data ---")
    price_data = fetch_live_price(ticker)
    print(json.dumps(price_data, indent=2))
    
    print("\n--- Top News Data ---")
    news_data = fetch_top_news(ticker)
    print(json.dumps(news_data, indent=2))
    
    if "error" in price_data or (len(news_data) > 0 and "error" in news_data[0]):
        print("\nNOTE: Make sure your SERPAPI_KEY is correctly set in backend/.env")

if __name__ == "__main__":
    main()
