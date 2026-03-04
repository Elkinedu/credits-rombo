from flask import Blueprint, request, jsonify
from app.customers.infrastructure.repository import SqlAlchemyCustomerRepository
from app.customers.application.use_cases import CreateCustomerUseCase

customers_bp = Blueprint("customers", __name__)
repository = SqlAlchemyCustomerRepository()
create_customer_uc = CreateCustomerUseCase(repository)

@customers_bp.route("/customers", methods=["POST"])
def create_customer():
    data = request.json
    customer = create_customer_uc.execute(data)
    return jsonify({
        "id": customer.id,
        "first_name": customer.first_name,
        "last_name": customer.last_name,
        "document_number": customer.document_number,
        "credit_score": customer.credit_score,
        "risk_classification": customer.risk_classification
    }), 201