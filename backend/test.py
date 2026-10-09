import asyncio
from main import analyze_portfolio

async def run():
    res = await analyze_portfolio(None, None, 'local', 'true')
    print("Prices updated:", res.get("prices_updated"))

if __name__ == "__main__":
    asyncio.run(run())
