-- Run this in Supabase Dashboard → SQL Editor if you get 404 on get_offer_checkout_if_approved.
-- Requires: public.offers table and RLS already in place.

CREATE OR REPLACE FUNCTION public.get_offer_checkout_if_approved(p_email TEXT, p_product_id UUID)
RETURNS TABLE (checkout_token TEXT, checkout_token_expires_at TIMESTAMPTZ)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT o.checkout_token, o.checkout_token_expires_at
  FROM public.offers o
  WHERE LOWER(TRIM(o.email)) = LOWER(TRIM(p_email))
    AND o.product_id = p_product_id
    AND o.status IN ('approved', 'countered')
    AND o.checkout_token IS NOT NULL
    AND o.checkout_token_expires_at > now()
  ORDER BY o.created_at DESC
  LIMIT 1;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_offer_checkout_if_approved(TEXT, UUID) TO anon;
GRANT EXECUTE ON FUNCTION public.get_offer_checkout_if_approved(TEXT, UUID) TO authenticated;
