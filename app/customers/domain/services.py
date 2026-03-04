def classify_risk(credit_score: int) -> str:
    if credit_score >= 800:
        return "A"
    elif credit_score >= 700:
        return "B"
    elif credit_score >= 600:
        return "C"
    elif credit_score >= 500:
        return "D"
    else:
        return "E"