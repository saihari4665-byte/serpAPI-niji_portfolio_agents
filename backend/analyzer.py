import os
import pandas as pd
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

import re

def clean_numeric(val) -> float:
    if pd.isna(val) or val is None:
        return 0.0
    val_str = str(val).strip()
    if not val_str:
        return 0.0
    # Remove currency symbols, commas, and percentage signs
    val_str = re.sub(r'[₹$,%]', '', val_str).strip()
    try:
        return float(val_str)
    except ValueError:
        return 0.0

def calculate_portfolio_weights(df: pd.DataFrame) -> dict:
    # Normalize headers for matching
    original_cols = list(df.columns)
    col_map = {}
    for col in original_cols:
        clean_col = re.sub(r'[^a-zA-Z0-9]', '', str(col).lower())
        col_map[clean_col] = col

    def get_col(aliases):
        for alias in aliases:
            clean_alias = re.sub(r'[^a-zA-Z0-9]', '', alias.lower())
            if clean_alias in col_map:
                return col_map[clean_alias]
        return None

    sym_col = get_col(["ticker", "symbol", "tradingsymbol", "tickersymbol", "instrument", "stockname", "company", "companyname", "name", "symbolname"]) or original_cols[0]
    qty_col = get_col(["qty", "quantity", "units", "shares", "noofshares"])
    buy_price_col = get_col(["avgprice", "averageprice", "averagebuyprice", "buyprice", "avgcost", "averagecost"])
    current_price_col = get_col(["ltp", "currentprice", "cmp", "marketprice", "lasttradedprice", "closeprice"])
    invested_col = get_col(["invested", "investedvalue", "investment", "investmentvalue", "buyvalue", "costvalue"])
    current_val_col = get_col(["currentvalue", "marketvalue", "presentvalue", "valuation"])
    sector_col = get_col(["sector", "industry"])
    pnl_col = get_col(["pnl", "pl", "profitloss", "unrealizedpnl", "unrealizedgainloss"])
    pnl_pct_col = get_col(["pnlpercent", "plpercent", "profitlosspercent", "returnpercent", "gainlosspercent"])

    holdings = {}
    total_invested = 0.0

    for index, row in df.iterrows():
        sym = str(row[sym_col]).strip()
        if not sym or sym == 'nan':
            continue

        qty = clean_numeric(row[qty_col]) if qty_col else 0.0
        buy_price = clean_numeric(row[buy_price_col]) if buy_price_col else 0.0
        current_price = clean_numeric(row[current_price_col]) if current_price_col else 0.0
        invested_value = clean_numeric(row[invested_col]) if invested_col else 0.0
        current_value = clean_numeric(row[current_val_col]) if current_val_col else 0.0
        
        # 1. Fill missing invested_value or buy_price
        if invested_value == 0.0 and qty > 0 and buy_price > 0:
            invested_value = qty * buy_price
        elif buy_price == 0.0 and qty > 0 and invested_value > 0:
            buy_price = invested_value / qty

        # 2. Fill missing current_value or current_price
        if current_value == 0.0 and qty > 0 and current_price > 0:
            current_value = qty * current_price
        elif current_price == 0.0 and qty > 0 and current_value > 0:
            current_price = current_value / qty

        # 3. Last resort fallbacks to prevent -100% P&L from parsing failures
        if current_price == 0.0 and buy_price > 0:
            current_price = buy_price
            
        if current_value == 0.0 and qty > 0 and current_price > 0:
            current_value = qty * current_price
        elif current_value == 0.0 and invested_value > 0 and qty > 0:
            current_value = invested_value

        pnl = clean_numeric(row[pnl_col]) if pnl_col else (current_value - invested_value)
        pnl_pct = clean_numeric(row[pnl_pct_col]) if pnl_pct_col else ((pnl / invested_value * 100) if invested_value > 0 else 0.0)

        # 4. Final sanity check: if current_value is 0 (or close to 0 due to missing data) and invested > 0, we must not let P&L be -100% just because LTP is 0.
        if (current_value == 0.0 or current_price == 0.0) and invested_value > 0.0:
            # Revert to cost basis to prevent artificial -100% returns
            current_value = invested_value
            if qty > 0:
                current_price = invested_value / qty
            pnl = 0.0
            pnl_pct = 0.0

        sector_val = str(row[sector_col]).strip() if sector_col and not pd.isna(row[sector_col]) else ""
        if not sector_val or sector_val == 'nan':
            # Basic fallback if sector is empty
            if "BANK" in sym.upper(): sector_val = "Banking"
            elif "TECH" in sym.upper() or "SOFT" in sym.upper() or sym.upper() in ["INFY", "TCS"]: sector_val = "IT"
            elif "POWER" in sym.upper() or "ENERGY" in sym.upper() or "WIND" in sym.upper() or sym.upper() in ["RELIANCE"]: sector_val = "Energy"
            else: sector_val = "Diversified"

        unique_key = f"{sym}_{index}"
        holdings[unique_key] = {
            "ticker": sym,
            "shares": qty,
            "avg_buy_price": buy_price,
            "current_price": current_price,
            "investment_value": invested_value,
            "current_value": current_value,
            "pnl": pnl,
            "pnl_percent": pnl_pct,
            "sector": sector_val
        }
        total_invested += invested_value

    if total_invested <= 0:
        total_invested = 1.0

    # Calculate weight percent
    for u_key in holdings:
        val = holdings[u_key]["current_value"]
        holdings[u_key]["weight_percent"] = round((val / total_invested) * 100, 2)

    return {
        "total_invested": float(total_invested),
        "holdings": holdings
    }

def calculate_health_score(holdings: dict, total_value: float) -> dict:
    if total_value <= 0:
        total_value = 1.0

    sector_values = {}
    max_concentration = 0.0

    for sym, data in holdings.items():
        val = data.get("current_value", data.get("investment_value", 0.0))
        if val < 0: val = 0.0 # Strict rule: only positive values for allocation
        sec = data.get("sector", "Uncategorized")
        sector_values[sec] = sector_values.get(sec, 0.0) + val

    total_positive_val = sum(sector_values.values())
    if total_positive_val <= 0:
        total_positive_val = 1.0

    sector_allocation = []
    for sec, val in sector_values.items():
        pct = round((val / total_positive_val * 100), 2)
        
        if pct > max_concentration:
            max_concentration = pct
            
        sector_allocation.append({"sector": sec, "percentage": pct})

    score = 85
    if max_concentration > 30:
        score -= 15

    num_sectors = len(sector_values.keys())
    if num_sectors < 3:
        score -= 10
    elif num_sectors > 5:
        score += 5

    score = max(0, min(100, score))

    if score >= 85:
        grade = "A"
        status = "Balanced Growth"
    elif score >= 70:
        grade = "B"
        status = "Moderate Risk"
    else:
        grade = "C"
        status = "High Concentration"

    return {
        "health_score": score,
        "health_grade": grade,
        "health_status": status,
        "sector_allocation": sector_allocation
    }

def analyze_portfolio_risk(weights: dict, market_data: dict, ai_mode: str = "local") -> str:
    prompt = (
        "You are an expert AI financial analyst. Assess the risk of the following stock portfolio.\n"
        "IMPORTANT RULES:\n"
        "1. These financial metrics were calculated by a deterministic local engine.\n"
        "2. Do not recalculate them. Do not modify them.\n"
        "3. Do not invent prices, holdings, or news.\n"
        "4. Explain the supplied portfolio facts.\n\n"
    )

    prompt += "### Portfolio Composition:\n"
    holdings_dict = weights.get("holdings", weights)
    
    total_invested = weights.get("total_invested", 0.0)
    total_current = sum(h.get("current_value", 0.0) for h in holdings_dict.values())
    total_pnl = sum(h.get("pnl", 0.0) for h in holdings_dict.values())
    total_pnl_pct = (total_pnl / total_invested * 100) if total_invested > 0 else 0.0
    
    prompt += f"Total Invested: {total_invested}\nTotal Current Value: {total_current}\nTotal P&L: {total_pnl}\nTotal P&L %: {total_pnl_pct}%\n\n"
    
    for symbol, data in holdings_dict.items():
        if isinstance(data, dict):
            pct = data.get("weight_percent", "N/A")
            sec = data.get("sector", "Diversified")
            qty = data.get("shares", 0)
            cp = data.get("current_price", 0)
            cv = data.get("current_value", 0)
            pnl = data.get("pnl", 0)
            pnl_pct = data.get("pnl_percent", 0)
            prompt += f"- {symbol} ({sec}): {qty} shares @ {cp} | Value: {cv} | P&L: {pnl} ({pnl_pct}%) | Weight: {pct}%\n"

    prompt += "\n### Current Market Data & Live SerpApi News:\n"
    for symbol, m_data in market_data.items():
        prompt += f"**{symbol}**:\n"
        price_info = m_data.get("price", {}) if isinstance(m_data, dict) else {}
        prompt += f"- Current Price: {price_info.get('current_price', 'N/A')} {price_info.get('currency', '')}\n"

        news = m_data.get("news", []) if isinstance(m_data, dict) else []
        if news and isinstance(news, list) and len(news) > 0 and "error" not in news[0]:
            prompt += "- Recent Headlines:\n"
            for item in news[:3]:
                prompt += f"  * {item.get('title', '')} ({item.get('source', '')})\n"

    prompt += "\n### Analysis Requirements:\n"
    prompt += "Generate an executive-grade structured JSON report. Do NOT wrap in markdown blocks, return ONLY valid JSON.\n"
    prompt += "Use exactly this schema:\n"
    prompt += "{\n"
    prompt += '  "executive_assessment": "Overall narrative on portfolio performance, main contributors, concentration, risk, and market context.",\n'
    prompt += '  "performance_explanation": "Detailed explanation of why the portfolio is making or losing money (top 3 reasons).",\n'
    prompt += '  "portfolio_health_score": 75,\n'
    prompt += '  "portfolio_health_status": "Moderate Concentration",\n'
    prompt += '  "concentration_analysis": "Explanation of what the current concentration means for risk, following Investor.gov framework.",\n'
    prompt += '  "sector_analysis": "Narrative on sector allocation, specific risks, and diversification implications.",\n'
    prompt += '  "profit_contributors": [{"holding": "TICKER", "reason": "Why it matters"}],\n'
    prompt += '  "loss_contributors": [{"holding": "TICKER", "reason": "Why it matters"}],\n'
    prompt += '  "market_context": [{"ticker": "TICKER", "headline": "string", "source": "string", "date": "string", "impact": "Why it matters & potential impact"}],\n'
    prompt += '  "risks": [{"type": "Concentration Risk", "description": "Specific to this portfolio"}],\n'
    prompt += '  "strengths": ["string"],\n'
    prompt += '  "concerns": ["string"],\n'
    prompt += '  "monitor_next": [{"holding": "TICKER", "priority": "High/Medium/Low", "reason": "Why"}],\n'
    prompt += '  "investor_questions": ["string"]\n'
    prompt += "}\n\n"
    prompt += "IMPORTANT: Ground all statements in the deterministic metrics provided. Do not hallucinate prices, and do not falsely claim causation from news without saying 'could have influenced' or 'likely contributor'. If no news, explicitly state it."

    if ai_mode == "none":
        return "{}"
    
    return call_local_llm(prompt)

def call_local_llm(prompt: str) -> str:
    base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434/v1")
    model_name = os.getenv("LOCAL_MODEL_NAME", "gemma2:2b")

    try:
        client = OpenAI(base_url=base_url, api_key="ollama")
        response = client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": "You are a professional financial analyst. Always respond in structured markdown."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=1500
        )
        return response.choices[0].message.content
    except Exception as e:
        return (
            f"### Local AI Offline Notice\n"
            f"Could not connect to Ollama model `{model_name}` at `{base_url}`.\n\n"
            f"**Error:** {str(e)}\n\n"
            f"Please ensure Ollama is running and the model is downloaded."
        )

import json

def run_rich_analysis(weights: dict, market_data: dict, ai_mode: str = "local") -> dict:
    llm_output = analyze_portfolio_risk(weights, market_data, ai_mode)
    
    # Try parsing the LLM output as JSON
    parsed_ai = None
    try:
        # Strip potential markdown wrapping from LLM
        clean_out = llm_output.strip()
        if clean_out.startswith("```json"):
            clean_out = clean_out[7:]
        if clean_out.startswith("```"):
            clean_out = clean_out[3:]
        if clean_out.endswith("```"):
            clean_out = clean_out[:-3]
        parsed_ai = json.loads(clean_out.strip())
    except Exception as e:
        print(f"LLM JSON parsing failed: {e}. Falling back to deterministic.")
        pass

    holdings = weights.get("holdings", {})
    tickers = list(holdings.keys())
    sectors = list({data.get("sector", "Diversified") for data in holdings.values()})
    total_invested = weights.get("total_invested", 1.0)
    
    biggest_sector = ""
    max_sector_weight = 0
    sector_weights = {}
    for sym, data in holdings.items():
        sec = data.get("sector", "Diversified")
        w = data.get("weight_percent", 0.0)
        sector_weights[sec] = sector_weights.get(sec, 0) + w

    for sec, w in sector_weights.items():
        if w > max_sector_weight:
            max_sector_weight = w
            biggest_sector = sec

    overall_str = f"Your portfolio is diversified across {len(sectors)} sectors. "
    if max_sector_weight > 30:
        overall_str += f"However, it shows a high concentration ({max_sector_weight:.1f}%) in {biggest_sector}, increasing risk exposure to that industry."
    else:
        overall_str += "Sector allocation is well balanced, indicating a moderate risk profile."
    
    strengths = [f"Verified asset allocations across {len(sectors)} identified sector(s)."]
    areas_to_improve = []
    if max_sector_weight > 40:
        areas_to_improve.append(f"Overexposure to {biggest_sector} sector ({max_sector_weight:.1f}%).")
        
    priority_matrix = []
    for sym in tickers:
        weight = holdings[sym].get("weight_percent", 0.0)
        score = round(min(95.0, 50.0 + weight * 1.2), 1)
        level = "High" if score > 75 else ("Medium" if score > 60 else "Low")
        priority_matrix.append({
            "company": sym, "sector": holdings[sym].get("sector", "Diversified"),
            "score": score, "level": level, "direction": "Negative" if level == "High" else "Neutral",
            "action": "Inspect ->"
        })
    priority_matrix = sorted(priority_matrix, key=lambda x: x["score"], reverse=True)

    if parsed_ai:
        return {
            "is_ai": True,
            "executive_assessment": parsed_ai.get("executive_assessment", overall_str),
            "performance_explanation": parsed_ai.get("performance_explanation", ""),
            "health_score": parsed_ai.get("portfolio_health_score", 75),
            "health_status": parsed_ai.get("portfolio_health_status", "Reviewed"),
            "concentration_analysis": parsed_ai.get("concentration_analysis", ""),
            "sector_analysis_text": parsed_ai.get("sector_analysis", ""),
            "profit_contributors": parsed_ai.get("profit_contributors", []),
            "loss_contributors": parsed_ai.get("loss_contributors", []),
            "market_context": parsed_ai.get("market_context", []),
            "risks": parsed_ai.get("risks", []),
            "strengths": parsed_ai.get("strengths", strengths),
            "concerns": parsed_ai.get("concerns", areas_to_improve),
            "monitor_next": parsed_ai.get("monitor_next", []),
            "investor_questions": parsed_ai.get("investor_questions", []),
            "research_priorities": priority_matrix,
        }
    else:
        return {
            "is_ai": False,
            "executive_assessment": overall_str,
            "performance_explanation": "Deterministic fallback mode active. Please check Ollama connection.",
            "health_score": round(100 - max(0, max_sector_weight - 30), 1),
            "health_status": "Fallback Mode",
            "concentration_analysis": "Deterministic mode: " + ("High concentration detected." if max_sector_weight > 30 else "Diversified."),
            "sector_analysis_text": "Deterministic mode: " + overall_str,
            "profit_contributors": [],
            "loss_contributors": [],
            "market_context": [],
            "risks": [{"type": "System Risk", "description": "AI Offline. Using local deterministic math only."}],
            "strengths": strengths,
            "concerns": areas_to_improve,
            "monitor_next": [],
            "investor_questions": ["Review overall concentration.", "Monitor top holdings."],
            "research_priorities": priority_matrix,
        }