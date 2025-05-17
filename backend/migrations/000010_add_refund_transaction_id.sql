-- Add refund_transaction_id column to psi_return_orders table
ALTER TABLE psi_return_orders ADD COLUMN IF NOT EXISTS refund_transaction_id VARCHAR(100);
