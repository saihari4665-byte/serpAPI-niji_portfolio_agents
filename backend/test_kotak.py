import os, sys, json
sys.path.append('.')
from dotenv import load_dotenv
load_dotenv()
from serpapi import GoogleSearch

def test_kotak():
    params = {
        "engine": "google_finance",
        "q": "KOTAKBANK:NSE",
        "api_key": os.getenv('SERPAPI_KEY')
    }
    search = GoogleSearch(params)
    res = search.get_dict()
    print(json.dumps({'summary': res.get('summary', {}), 'error': res.get('error')}, indent=2))

test_kotak()
