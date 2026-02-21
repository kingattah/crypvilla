-- Fix: Checkout was failing with "Order could not be saved" because the client
-- does insert(order).select('id').single() to get the new order id for order_items.
-- Anon had INSERT but no SELECT on orders, so the RETURNING row was blocked by RLS.
-- This policy allows anon to read from orders so the insert response is returned.
-- Run this in Supabase SQL Editor once.

DROP POLICY IF EXISTS "orders_select_anon" ON public.orders;
CREATE POLICY "orders_select_anon" ON public.orders
  FOR SELECT USING (true);
