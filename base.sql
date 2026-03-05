-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE risk_classification_enum AS ENUM ('A','B','C','D','E');

CREATE TYPE amortization_type_enum AS ENUM (
    'CUOTA_FIJA',
    'ABONO_CONSTANTE_CAPITAL'
);

CREATE TYPE loan_status_enum AS ENUM (
    'RADICADO',
    'APROBADO',
    'DESEMBOLSADO',
    'AL_DIA',
    'EN_MORA',
    'REESTRUCTURADO',
    'CASTIGADO',
    'PAGADO'
);

CREATE TYPE payment_method_enum AS ENUM (
    'PSE',
    'CONSIGNACION',
    'DEBITO_AUTOMATICO',
    'CORRESPONSAL_BANCARIO'
);

CREATE TYPE accounting_entry_type_enum AS ENUM ('DEBITO','CREDITO');


-- =====================================================
-- CUSTOMERS
-- =====================================================

CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    document_type VARCHAR(20) NOT NULL,
    document_number VARCHAR(30) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    business_name VARCHAR(200),
    email VARCHAR(150),
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(100) NOT NULL,
    credit_score INTEGER CHECK (credit_score BETWEEN 0 AND 1000),
    risk_classification risk_classification_enum NOT NULL DEFAULT 'A',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_customer_document UNIQUE (document_type, document_number)
);

CREATE INDEX idx_customers_document_number 
ON customers(document_number);


-- =====================================================
-- LOANS
-- =====================================================

CREATE TABLE loans (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    requested_amount NUMERIC(18,2) NOT NULL CHECK (requested_amount > 0),
    approved_amount NUMERIC(18,2) NOT NULL CHECK (approved_amount > 0),
    interest_rate NUMERIC(7,4) NOT NULL,
    interest_rate_type VARCHAR(20) NOT NULL, -- EA, NMV
    term_months INTEGER NOT NULL CHECK (term_months > 0),
    amortization_type amortization_type_enum NOT NULL,
    status loan_status_enum NOT NULL DEFAULT 'RADICADO',
    filing_date DATE NOT NULL DEFAULT CURRENT_DATE,
    disbursement_date DATE,
    outstanding_principal NUMERIC(18,2),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_loans_status ON loans(status);


-- =====================================================
-- AMORTIZATION SCHEDULE
-- =====================================================

CREATE TABLE amortization_schedule (
    id BIGSERIAL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    due_date DATE NOT NULL,
    principal_amount NUMERIC(18,2) NOT NULL,
    interest_amount NUMERIC(18,2) NOT NULL,
    life_insurance_amount NUMERIC(18,2) NOT NULL DEFAULT 0,
    other_charges NUMERIC(18,2) NOT NULL DEFAULT 0,
    total_installment NUMERIC(18,2) NOT NULL,
    remaining_principal NUMERIC(18,2) NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_loan_installment UNIQUE (loan_id, installment_number)
);

CREATE INDEX idx_amortization_loan_id 
ON amortization_schedule(loan_id);

CREATE INDEX idx_amortization_due_date 
ON amortization_schedule(due_date);


-- =====================================================
-- PAYMENTS
-- =====================================================

CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES loans(id),
    payment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    amount_paid NUMERIC(18,2) NOT NULL CHECK (amount_paid > 0),
    payment_reference VARCHAR(100) NOT NULL,
    payment_method payment_method_enum NOT NULL,
    is_applied BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_payment_reference UNIQUE (payment_reference)
);

CREATE INDEX idx_payments_loan_id 
ON payments(loan_id);


-- =====================================================
-- PAYMENT ALLOCATIONS (legal waterfall order)
-- =====================================================

CREATE TABLE payment_allocations (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    concept VARCHAR(50) NOT NULL, 
    -- COSTAS_JUDICIALES, SEGUROS, INTERES_MORA, INTERES_CORRIENTE, CAPITAL
    allocated_amount NUMERIC(18,2) NOT NULL CHECK (allocated_amount >= 0)
);


-- =====================================================
-- ACCOUNTING (DOUBLE ENTRY)
-- =====================================================

CREATE TABLE chart_of_accounts (
    id BIGSERIAL PRIMARY KEY,
    account_code VARCHAR(20) NOT NULL UNIQUE,
    account_name VARCHAR(150) NOT NULL,
    nature accounting_entry_type_enum NOT NULL -- DEBITO or CREDITO
);

CREATE TABLE journal_entries (
    id BIGSERIAL PRIMARY KEY,
    entry_date TIMESTAMP NOT NULL DEFAULT NOW(),
    description TEXT NOT NULL,
    reference VARCHAR(100)
);

CREATE TABLE journal_entry_lines (
    id BIGSERIAL PRIMARY KEY,
    journal_entry_id BIGINT NOT NULL 
        REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id BIGINT NOT NULL 
        REFERENCES chart_of_accounts(id),
    entry_type accounting_entry_type_enum NOT NULL,
    amount NUMERIC(18,2) NOT NULL CHECK (amount > 0)
);

CREATE INDEX idx_journal_lines_entry_id 
ON journal_entry_lines(journal_entry_id);