-- Security fix: orders/order_items no longer writable or readable by anon.
-- Order creation is done only via Edge Functions (verify-and-create-order / verify-and-complete-offer)
-- which use the service role after verifying Paystack payment.
-- Run this in Supabase SQL Editor after deploying the Edge Functions and setting PAYSTACK_SECRET_KEY.

-- 1. Remove anon insert/select on orders (Edge Function will insert with service role)
DROP POLICY IF EXISTS "orders_insert" ON public.orders;
DROP POLICY IF EXISTS "orders_select_anon" ON public.orders;

-- 2. Remove anon insert on order_items (Edge Function inserts with service role)
DROP POLICY IF EXISTS "order_items_insert" ON public.order_items;

-- 3. complete_offer_payment: only callable from Edge Function (service role), not from browser
REVOKE EXECUTE ON FUNCTION public.complete_offer_payment(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) FROM anon;
REVOKE EXECUTE ON FUNCTION public.complete_offer_payment(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.complete_offer_payment(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO service_role;

-- 4. Prevent same Paystack reference being used twice (replay protection)
CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_paystack_reference_unique
  ON public.orders (paystack_reference) WHERE paystack_reference IS NOT NULL;

-- Admin policies (from schema-admin-auth.sql) remain: admins can SELECT/UPDATE orders and order_items.
