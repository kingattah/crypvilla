-- Run this if you already have the orders table with payaza_reference/payaza_status.
-- Adds Paystack columns; old Payaza data is left in place for existing orders.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS paystack_reference TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS paystack_status TEXT;
