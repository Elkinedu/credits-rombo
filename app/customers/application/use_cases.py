from app.customers.domain.entities import Customer

class CreateCustomerUseCase:
    def __init__(self, repository):
        self.repository = repository

    def execute(self, customer_data: dict):
        customer = Customer(**customer_data)
        saved_customer = self.repository.save(customer)
        return saved_customer