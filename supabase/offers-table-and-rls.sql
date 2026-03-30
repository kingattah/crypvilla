-- Make an Offer: offers table, RLS, and RPCs.
-- Run AFTER schema.sql and schema-admin-auth.sql.

-- 1. Offers table (must exist before adding orders.offer_id FK)
CREATE TABLE IF NOT EXISTS public.offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  original_price NUMERIC(12, 2) NOT NULL,
  offered_price NUMERIC(12, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'countered', 'completed', 'expired')),
  counter_price NUMERIC(12, 2) NULL,
  email TEXT NOT NULL,
  reason TEXT NULL,
  expires_at TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  checkout_token TEXT UNIQUE NULL,
  checkout_token_expires_at TIMESTAMPTZ NULL,
  quantity INT NOT NULL DEFAULT 1
);

-- 2b. Add quantity column if table already existed without it
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'offers' AND column_name = 'quantity'
  ) THEN
    ALTER TABLE public.offers ADD COLUMN quantity INT NOT NULL DEFAULT 1;
  END IF;
END $$;

-- 2c. Add rejection_message so admin can give a reason or best price when rejecting
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'offers' AND column_name = 'rejection_message'
  ) THEN
    ALTER TABLE public.offers ADD COLUMN rejection_message TEXT NULL;
  END IF;
END $$;

-- 2d. Add whatsapp_number so admin can contact offer customers directly
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'offers' AND column_name = 'whatsapp_number'
  ) THEN
    ALTER TABLE public.offers ADD COLUMN whatsapp_number TEXT NULL;
  END IF;
END $$;

-- 3. Add offer_id to orders (after offers exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'orders' AND column_name = 'offer_id'
  ) THEN
    ALTER TABLE public.orders ADD COLUMN offer_id UUID NULL REFERENCES public.offers(id);
  END IF;
END $$;

-- 4. Indexes
CREATE INDEX IF NOT EXISTS idx_offers_product_id ON public.offers(product_id);
CREATE INDEX IF NOT EXISTS idx_offers_email ON public.offers(email);
CREATE INDEX IF NOT EXISTS idx_offers_created_at ON public.offers(created_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_offers_checkout_token ON public.offers(checkout_token) WHERE checkout_token IS NOT NULL;

-- 5. RLS on offers
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

-- No anon policies: anon uses RPCs only
-- Admin can select and update (for manual approve/reject)
DROP POLICY IF EXISTS "offers_admin_select" ON public.offers;
CREATE POLICY "offers_admin_select" ON public.offers
  FOR SELECT USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "offers_admin_update" ON public.offers;
CREATE POLICY "offers_admin_update" ON public.offers
  FOR UPDATE USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- 6. submit_offer: rate limit, insert, manual review workflow, return JSON
DROP FUNCTION IF EXISTS public.submit_offer(UUID, NUMERIC, TEXT, TEXT, INT);
DROP FUNCTION IF EXISTS public.submit_offer(UUID, NUMERIC, TEXT, TEXT, TEXT, INT);
CREATE OR REPLACE FUNCTION public.submit_offer(
  p_product_id UUID,
  p_offered_price NUMERIC,
  p_email TEXT,
  p_whatsapp_number TEXT DEFAULT NULL,
  p_reason TEXT DEFAULT NULL,
  p_quantity INT DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_original_price NUMERIC(12, 2);
  v_recent_count INT;
  v_quantity INT;
BEGIN
  p_email := LOWER(TRIM(p_email));
  p_whatsapp_number := NULLIF(TRIM(COALESCE(p_whatsapp_number, '')), '');
  v_quantity := COALESCE(NULLIF(p_quantity, 0), 1);
  IF v_quantity < 1 THEN
    v_quantity := 1;
  END IF;
  IF p_email = '' OR p_offered_price IS NULL OR p_offered_price < 0 THEN
    RETURN jsonb_build_object('status', 'error', 'message', 'Invalid email or offer price.');
  END IF;

  -- Rate limit: max 10 offers per email per hour (rolling)
  SELECT COUNT(*)::INT INTO v_recent_count
  FROM public.offers
  WHERE LOWER(TRIM(email)) = p_email
    AND created_at > now() - interval '1 hour';

  IF v_recent_count >= 10 THEN
    RETURN jsonb_build_object(
      'status', 'rate_limited',
      'message', 'Limit: 10 offers per hour. Please try again later.'
    );
  END IF;

  -- Load product price
  SELECT price INTO v_original_price FROM public.products WHERE id = p_product_id;
  IF v_original_price IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'message', 'Product not found.');
  END IF;

  -- Reject offers < 80% (of single-unit price; compare total to total)
  IF p_offered_price < 0.80 * (v_original_price * v_quantity) THEN
    INSERT INTO public.offers (product_id, original_price, offered_price, email, whatsapp_number, reason, status, quantity)
    VALUES (p_product_id, v_original_price * v_quantity, p_offered_price, p_email, p_whatsapp_number, p_reason, 'rejected', v_quantity);
    RETURN jsonb_build_object(
      'status', 'rejected',
      'message', 'Your offer was below our minimum threshold. Please keep shopping for something more affordable, or contact us via WhatsApp for recommendations.'
    );
  END IF;

  -- Insert offer (pending first); original_price stored as total (unit price * quantity)
  INSERT INTO public.offers (product_id, original_price, offered_price, email, whatsapp_number, reason, status, quantity)
  VALUES (p_product_id, v_original_price * v_quantity, p_offered_price, p_email, p_whatsapp_number, p_reason, 'pending', v_quantity);

  -- No automatic acceptance: all valid offers >= 80% require admin review.
  -- This applies to all quantities, including 1-3 devices.
  RETURN jsonb_build_object(
    'status', 'pending',
    'message', 'Your offer is under review. We will get back to you shortly once it has been reviewed.'
  );
END;
$$;

-- 7. validate_offer_checkout: return offer details for checkout (single row or empty)
-- Drop first when return type changes (e.g. added quantity column)
DROP FUNCTION IF EXISTS public.validate_offer_checkout(TEXT);
CREATE OR REPLACE FUNCTION public.validate_offer_checkout(p_token TEXT)
RETURNS TABLE (
  offer_id UUID,
  product_id UUID,
  original_price NUMERIC,
  offered_price NUMERIC,
  counter_price NUMERIC,
  status TEXT,
  email TEXT,
  final_amount NUMERIC,
  product_snapshot JSONB,
  category_slug TEXT,
  quantity INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row RECORD;
BEGIN
  IF p_token IS NULL OR p_token = '' THEN
    RETURN;
  END IF;

  SELECT o.id, o.product_id, o.original_price, o.offered_price, o.counter_price, o.status, o.email,
         CASE WHEN o.status = 'approved' THEN o.offered_price ELSE o.counter_price END AS final_amt,
         jsonb_build_object(
           'name', p.name,
           'image_url', p.image_url,
           'description', p.description
         ) AS snap,
         c.slug AS cat_slug,
         COALESCE(o.quantity, 1) AS qty
  INTO v_row
  FROM public.offers o
  JOIN public.products p ON p.id = o.product_id
  LEFT JOIN public.categories c ON c.id = p.category_id
  WHERE o.checkout_token = p_token
    AND o.checkout_token_expires_at > now()
    AND o.status IN ('approved', 'countered')
    AND o.status <> 'completed';

  IF v_row.id IS NULL THEN
    RETURN;
  END IF;

  offer_id := v_row.id;
  product_id := v_row.product_id;
  original_price := v_row.original_price;
  offered_price := v_row.offered_price;
  counter_price := v_row.counter_price;
  status := v_row.status;
  email := v_row.email;
  final_amount := v_row.final_amt;
  product_snapshot := v_row.snap;
  category_slug := v_row.cat_slug;
  quantity := v_row.qty;
  RETURN NEXT;
END;
$$;

-- 8. complete_offer_payment: mark offer completed, create order + order_item
CREATE OR REPLACE FUNCTION public.complete_offer_payment(
  p_token TEXT,
  p_paystack_reference TEXT,
  p_customer_name TEXT,
  p_customer_phone TEXT,
  p_delivery_address TEXT,
  p_delivery_location TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_offer RECORD;
  v_order_id UUID;
  v_order_number TEXT;
  v_subtotal NUMERIC(12, 2);
  v_shipping NUMERIC(12, 2) := 0;
  v_total NUMERIC(12, 2);
  v_snapshot JSONB;
BEGIN
  IF p_token IS NULL OR p_token = '' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid token.');
  END IF;

  SELECT o.id, o.product_id, o.email, o.offered_price, o.counter_price, o.status,
         CASE WHEN o.status = 'approved' THEN o.offered_price ELSE o.counter_price END AS final_amt,
         p.name AS product_name, p.image_url,
         COALESCE(o.quantity, 1) AS qty
  INTO v_offer
  FROM public.offers o
  JOIN public.products p ON p.id = o.product_id
  WHERE o.checkout_token = p_token
    AND o.checkout_token_expires_at > now()
    AND o.status IN ('approved', 'countered');

  IF v_offer.id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid or expired offer.');
  END IF;

  v_subtotal := v_offer.final_amt;
  v_total := v_subtotal + v_shipping;
  v_order_number := 'CRV-' || to_char(now(), 'YYYYMMDD') || '-' || upper(substring(gen_random_uuid()::text from 1 for 8));

  v_snapshot := jsonb_build_object(
    'name', v_offer.product_name,
    'price', ROUND((v_offer.final_amt / v_offer.qty)::numeric, 2),
    'image_url', v_offer.image_url
  );

  -- Mark offer completed and clear token (prevent reuse)
  UPDATE public.offers
  SET status = 'completed', checkout_token = NULL, checkout_token_expires_at = NULL
  WHERE id = v_offer.id;

  -- Create order (offer_id linked after we have order; we need to add offer_id to orders - we do it in the INSERT)
  INSERT INTO public.orders (
    order_number, customer_email, customer_name, customer_phone, delivery_address,
    subtotal, shipping, total, status, paystack_reference, paystack_status, offer_id
  )
  VALUES (
    v_order_number, v_offer.email, p_customer_name, p_customer_phone, p_delivery_address,
    v_subtotal, v_shipping, v_total, 'paid', p_paystack_reference, 'success', v_offer.id
  )
  RETURNING id INTO v_order_id;

  -- Create order_item(s): one row with quantity and per-unit price
  INSERT INTO public.order_items (order_id, product_id, product_snapshot, quantity, price)
  VALUES (v_order_id, v_offer.product_id, v_snapshot, v_offer.qty, ROUND((v_offer.final_amt / v_offer.qty)::numeric, 2));

  RETURN jsonb_build_object('success', true, 'order_number', v_order_number, 'order_id', v_order_id);
END;
$$;

-- 9. get_offer_checkout_if_approved: for client polling when offer was pending; returns token if now approved
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

-- Grant execute to anon and authenticated (for RPCs)
GRANT EXECUTE ON FUNCTION public.submit_offer(UUID, NUMERIC, TEXT, TEXT, TEXT, INT) TO anon;
GRANT EXECUTE ON FUNCTION public.submit_offer(UUID, NUMERIC, TEXT, TEXT, TEXT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.validate_offer_checkout(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.validate_offer_checkout(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_offer_payment(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.complete_offer_payment(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_offer_checkout_if_approved(TEXT, UUID) TO anon;
GRANT EXECUTE ON FUNCTION public.get_offer_checkout_if_approved(TEXT, UUID) TO authenticated;

-- 10. get_offer_status_for_customer: for "Check status" — returns status, token if approved/countered, or rejection_message/counter_price
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
