import asyncio
from main import get_current_dataframe, calculate_portfolio_weights

def test():
    df = get_current_dataframe()
    weights = calculate_portfolio_weights(df)
    tickers = list(weights["holdings"].keys())
    print("Tickers in portfolio:", tickers)

test()
