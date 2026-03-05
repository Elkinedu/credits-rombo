from app.customers.infrastructure.models import CustomerModel
from app.customers.application.ports import CustomerRepositoryPort
from app.extensions import db
from app.customers.domain.entities import Customer
from app.customers.domain.services import classify_risk

class SqlAlchemyCustomerRepository(CustomerRepositoryPort):

    def save(self, customer: Customer) -> Customer:
        model = CustomerModel(
            document_type=customer.document_type,
            document_number=customer.document_number,
            first_name=customer.first_name,
            last_name=customer.last_name,
            email=customer.email,
            phone=customer.phone,
            city=customer.city,
            credit_score=customer.credit_score,
            risk_classification=classify_risk(customer.credit_score),
        )
        db.session.add(model)
        db.session.commit()
        customer.id = model.id
        customer.risk_classification = classify_risk(customer.credit_score)
        return customer

    def get_by_id(self, customer_id):
        model = CustomerModel.query.get(customer_id)
        if model:
            return Customer(
                id=model.id,
                document_type=model.document_type,
                document_number=model.document_number,
                first_name=model.first_name,
                last_name=model.last_name,
                email=model.email,
                phone=model.phone,
                city=model.city,
                credit_score=model.credit_score,
                risk_classification=model.risk_classification,
            )
        return None

    def get_by_document(self, document_number):
        model = CustomerModel.query.filter_by(document_number=document_number).first()
        if model:
            return Customer(
                id=model.id,
                document_type=model.document_type,
                document_number=model.document_number,
                first_name=model.first_name,
                last_name=model.last_name,
                email=model.email,
                phone=model.phone,
                city=model.city,
                credit_score=model.credit_score,
                risk_classification=model.risk_classification,
            )
        return None