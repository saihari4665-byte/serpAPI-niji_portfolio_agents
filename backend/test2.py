from serpapi_service import fetch_live_price

print(fetch_live_price("BANKINDIA", force_refresh=True))
