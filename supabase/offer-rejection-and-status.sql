-- Offer rejection message + customer-visible status.
-- Run in Supabase SQL Editor. Requires: offers table and get_offer_checkout_if_approved.

-- 1. Add rejection_message so admin can tell the customer why / best price
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'offers' AND column_name = 'rejection_message'
  ) THEN
    ALTER TABLE public.offers ADD COLUMN rejection_message TEXT NULL;
  END IF;
END $$;

-- 2. RPC: customer checks status by email + product; returns latest offer status + token or rejection info
CREATE OR REPLACE FUNCTION public.get_offer_status_for_customer(p_email TEXT, p_product_id UUID)
RETURNS TABLE (
  status TEXT,
  checkout_token TEXT,
  checkout_token_expires_at TIMESTAMPTZ,
  counter_price NUMERIC,
  rejection_message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    o.status::TEXT,
    CASE
      WHEN o.status IN ('approved', 'countered') AND o.checkout_token IS NOT NULL AND o.checkout_token_expires_at > now()
      THEN o.checkout_token ELSE NULL
    END,
    o.checkout_token_expires_at,
    o.counter_price,
    o.rejection_message
  FROM public.offers o
  WHERE LOWER(TRIM(o.email)) = LOWER(TRIM(p_email))
    AND o.product_id = p_product_id
  ORDER BY o.created_at DESC
  LIMIT 1;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_offer_status_for_customer(TEXT, UUID) TO anon;
GRANT EXECUTE ON FUNCTION public.get_offer_status_for_customer(TEXT, UUID) TO authenticated;
