-- Migration to create tables for return and exchange management

-- psi_return_orders: Stores the main return/exchange order information
CREATE TABLE IF NOT EXISTS psi_return_orders (
    id SERIAL PRIMARY KEY,
    return_no VARCHAR(50) UNIQUE NOT NULL,
    order_no VARCHAR(50) NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'RETURN', 'EXCHANGE'
    status VARCHAR(30) NOT NULL, -- 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', etc.
    customer_name VARCHAR(100),
    customer_phone VARCHAR(50),
    apply_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    images TEXT, -- JSON string array of URLs

    -- Return specific fields
    refund_amount NUMERIC(10, 2),
    actual_refund_amount NUMERIC(10, 2),
    refund_method VARCHAR(50),
    refund_date TIMESTAMPTZ,

    -- Exchange specific fields
    exchange_shipping_address VARCHAR(255),
    exchange_shipping_contact VARCHAR(100),
    exchange_shipping_phone VARCHAR(50),
    exchange_shipping_no VARCHAR(100),

    -- Approval info
    approved_by INTEGER REFERENCES psi_users(id) ON DELETE SET NULL,
    approval_date TIMESTAMPTZ,
    rejection_reason TEXT,

    -- Processing info
    processed_by INTEGER REFERENCES psi_users(id) ON DELETE SET NULL,
    process_date TIMESTAMPTZ,
    completed_date TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_psi_return_orders_order_no ON psi_return_orders(order_no);
CREATE INDEX IF NOT EXISTS idx_psi_return_orders_status ON psi_return_orders(status);
CREATE INDEX IF NOT EXISTS idx_psi_return_orders_deleted_at ON psi_return_orders(deleted_at);

-- psi_return_order_items: Stores items being returned
CREATE TABLE IF NOT EXISTS psi_return_order_items (
    id SERIAL PRIMARY KEY,
    return_order_id INTEGER NOT NULL REFERENCES psi_return_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES psi_products(id) ON DELETE RESTRICT, -- Assuming psi_products table exists
    product_name VARCHAR(255) NOT NULL, -- Denormalized for easier display
    product_sku VARCHAR(100), -- Denormalized
    quantity INTEGER NOT NULL,
    reason VARCHAR(255), -- 'QUALITY', 'SIZE', 'STYLE', 'OTHER'
    remarks TEXT,
    received_quantity INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_psi_return_order_items_return_order_id ON psi_return_order_items(return_order_id);
CREATE INDEX IF NOT EXISTS idx_psi_return_order_items_product_id ON psi_return_order_items(product_id);

-- psi_exchange_order_items: Stores items being sent out as exchange
CREATE TABLE IF NOT EXISTS psi_exchange_order_items (
    id SERIAL PRIMARY KEY,
    return_order_id INTEGER NOT NULL REFERENCES psi_return_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES psi_products(id) ON DELETE RESTRICT, -- Assuming psi_products table exists
    product_name VARCHAR(255) NOT NULL, -- Denormalized
    product_sku VARCHAR(100), -- Denormalized
    quantity INTEGER NOT NULL,
    shipped_quantity INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_psi_exchange_order_items_return_order_id ON psi_exchange_order_items(return_order_id);
CREATE INDEX IF NOT EXISTS idx_psi_exchange_order_items_product_id ON psi_exchange_order_items(product_id);

-- psi_return_order_logs: Stores audit trail for return/exchange orders
CREATE TABLE IF NOT EXISTS psi_return_order_logs (
    id SERIAL PRIMARY KEY,
    return_order_id INTEGER NOT NULL REFERENCES psi_return_orders(id) ON DELETE CASCADE,
    operator_id INTEGER REFERENCES psi_users(id) ON DELETE SET NULL, -- Can be system (NULL) or a user
    operator_name VARCHAR(100),
    action VARCHAR(255) NOT NULL,
    details TEXT,
    log_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_psi_return_order_logs_return_order_id ON psi_return_order_logs(return_order_id);

-- Update updated_at timestamp on row update for psi_return_orders
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_psi_return_orders_updated_at
    BEFORE UPDATE
    ON
        psi_return_orders
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- Note: You might need to adjust table names (psi_users, psi_products) and foreign key constraints
-- based on your existing database schema.
-- Remember to replace '00000X' in the filename with the next sequential migration number.