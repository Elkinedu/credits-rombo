from abc import ABC, abstractmethod

class CustomerRepositoryPort(ABC):

    @abstractmethod
    def save(self, customer):
        pass

    @abstractmethod
    def get_by_id(self, customer_id):
        pass

    @abstractmethod
    def get_by_document(self, document_number):
        pass