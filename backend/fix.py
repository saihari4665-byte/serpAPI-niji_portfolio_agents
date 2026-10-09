import re

with open("main.py", "r", encoding="utf-8") as f:
    code = f.read()

# Replace weights["holdings"][ticker] with weights["holdings"][u_key]
code = code.replace('weights["holdings"][ticker]', 'weights["holdings"][u_key]')
code = code.replace('{ticker} -> Cleaned price:', '{actual_ticker} -> Cleaned price:')
code = code.replace('{ticker} -> Parsing failed', '{actual_ticker} -> Parsing failed')

with open("main.py", "w", encoding="utf-8") as f:
    f.write(code)
print("done")
