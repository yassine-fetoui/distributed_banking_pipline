-- ================================================
-- Enhanced Banking Schema - Customers, Accounts, Transactions
-- PostgreSQL Best Practices (2026)
-- ================================================

-- Enable extensions if needed (e.g., for UUIDs or advanced features)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- 1. Customers Table
-- ================================================
CREATE TABLE customers (
    customer_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    first_name         VARCHAR(100) NOT NULL,
    last_name          VARCHAR(100) NOT NULL,
    email              VARCHAR(255) UNIQUE NOT NULL,
    
    -- Optional but recommended fields
    phone              VARCHAR(30),
    date_of_birth      DATE,
    address            TEXT,

    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE customers IS 'Core customer information';
COMMENT ON COLUMN customers.email IS 'Unique email address used for login and communication';

-- ================================================
-- 2. Accounts Table
-- ================================================
CREATE TABLE accounts (
    account_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id        BIGINT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,

    -- Business-friendly identifier (e.g., IBAN-like or internal number)
    account_number     VARCHAR(34) UNIQUE NOT NULL,

    account_type       VARCHAR(50) NOT NULL CHECK (account_type IN ('checking', 'savings', 'credit', 'investment', 'loan')),
    currency           VARCHAR(3)  NOT NULL DEFAULT 'USD' CHECK (currency ~ '^[A-Z]{3}$'),

    balance            NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    
    status             VARCHAR(20) NOT NULL DEFAULT 'active' 
                       CHECK (status IN ('active', 'frozen', 'closed', 'suspended')),

    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE accounts IS 'Customer bank accounts with current balance';
COMMENT ON COLUMN accounts.balance IS 'Current available balance in the specified currency';

-- ================================================
-- 3. Transactions Table
-- ================================================
CREATE TABLE transactions (
    transaction_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    account_id         BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    related_account_id BIGINT NULL REFERENCES accounts(account_id) ON DELETE SET NULL,

    amount             NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    transaction_type   VARCHAR(50) NOT NULL 
                       CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer', 'payment', 'fee', 'interest')),

    transaction_date   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    description        TEXT,
    status             VARCHAR(20) NOT NULL DEFAULT 'completed' 
                       CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),

    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE transactions IS 'All financial movements (debits/credits) with full audit trail';
COMMENT ON COLUMN transactions.related_account_id IS 'For transfers: the counterparty account';

-- ================================================
-- Indexes for Performance
-- ================================================

-- Foreign key indexes (explicit for better join performance)
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_related_account_id ON transactions(related_account_id);

-- Common query patterns
CREATE INDEX idx_transactions_transaction_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_account_date ON transactions(account_id, transaction_date DESC);

-- Email search (if frequent)
CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));

-- ================================================
-- Automatic updated_at trigger function
-- ================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to tables that need it
CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_accounts_updated_at
    BEFORE UPDATE ON accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Note: transactions usually don't need updated_at since they are immutable (append-only)

-- ================================================
-- Optional: Row Level Security / Policies (for multi-tenant later)
-- ================================================
-- ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
-- ... etc.
