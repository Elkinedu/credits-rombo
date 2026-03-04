from app.extensions import db

class CustomerModel(db.Model):
    __tablename__ = "customers"

    id = db.Column(db.BigInteger, primary_key=True)
    document_type = db.Column(db.String(10), nullable=False)
    document_number = db.Column(db.String(30), nullable=False, unique=True)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100))
    phone = db.Column(db.String(30))
    city = db.Column(db.String(50))
    credit_score = db.Column(db.Integer, default=0)
    risk_classification = db.Column(db.String(1))