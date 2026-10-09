import os, json
import pandas as pd
from dotenv import load_dotenv
load_dotenv()
from serpapi import GoogleSearch

df = pd.read_csv('../data/latest_portfolio.csv')
tickers = df['Instrument'].tolist()

print("Ticker | Requested Instrument | Returned Instrument | Exchange | Price | Valid/Invalid")
print("-" * 100)

valid_count = 0
for ticker in tickers:
    params = {
        "engine": "google_finance",
        "q": f"{ticker}:NSE",
        "api_key": os.getenv('SERPAPI_KEY')
    }
    try:
        search = GoogleSearch(params)
        res = search.get_dict()
        summary = res.get("summary", {})
        
        returned_inst = summary.get("title", "None")
        returned_exch = summary.get("exchange", "None")
        price = summary.get("extracted_price", "None")
        
        # Validation Logic
        is_valid = False
        if returned_exch == "NSE" and str(price) != "None":
            stock_field = summary.get("stock", "")
            if stock_field.upper() == ticker.upper() or ticker.upper() in returned_inst.upper():
                is_valid = True
                valid_count += 1
                
        status = "Valid" if is_valid else "Invalid"
        print(f"{ticker} | {ticker}:NSE | {returned_inst} | {returned_exch} | {price} | {status}")
    except Exception as e:
        print(f"{ticker} | {ticker}:NSE | Error | Error | Error | Invalid")

print(f"\nSuccessfully updated: {valid_count}/{len(tickers)}")
