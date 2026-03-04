from dataclasses import dataclass

@dataclass
class Customer:
    id: int = None
    document_type: str = None
    document_number: str = None
    first_name: str = None
    last_name: str = None
    email: str = None
    phone: str = None
    city: str = None
    credit_score: int = 0
    risk_classification: str = None