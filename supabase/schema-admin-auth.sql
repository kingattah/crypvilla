-- Run this in Supabase SQL Editor AFTER the main schema and AFTER enabling Email auth in Authentication → Providers.
-- This allows admin users (logged in via Supabase Auth) to manage products, orders, and storage — no secret key in the browser.

-- Table of admin user IDs (you add users here after they sign up)
CREATE TABLE IF NOT EXISTS public.admin_users (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Only the current user can see if they are in the list (so the app can show/hide admin UI)
DROP POLICY IF EXISTS "admin_users_select_own" ON public.admin_users;
CREATE POLICY "admin_users_select_own" ON public.admin_users
  FOR SELECT USING (auth.uid() = user_id);

-- Only existing admins can add more admins (optional; run first admin insert via Dashboard)
-- CREATE POLICY "admin_users_insert" ON public.admin_users FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Products: allow full access for admins
DROP POLICY IF EXISTS "products_admin_insert" ON public.products;
DROP POLICY IF EXISTS "products_admin_update" ON public.products;
DROP POLICY IF EXISTS "products_admin_delete" ON public.products;
CREATE POLICY "products_admin_insert" ON public.products
  FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));
CREATE POLICY "products_admin_update" ON public.products
  FOR UPDATE USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));
CREATE POLICY "products_admin_delete" ON public.products
  FOR DELETE USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Categories: allow full access for admins
DROP POLICY IF EXISTS "categories_admin_insert" ON public.categories;
DROP POLICY IF EXISTS "categories_admin_update" ON public.categories;
DROP POLICY IF EXISTS "categories_admin_delete" ON public.categories;
CREATE POLICY "categories_admin_insert" ON public.categories
  FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));
CREATE POLICY "categories_admin_update" ON public.categories
  FOR UPDATE USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));
CREATE POLICY "categories_admin_delete" ON public.categories
  FOR DELETE USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Orders: allow admins to read and update (e.g. status)
DROP POLICY IF EXISTS "orders_admin_select" ON public.orders;
DROP POLICY IF EXISTS "orders_admin_update" ON public.orders;
CREATE POLICY "orders_admin_select" ON public.orders
  FOR SELECT USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));
CREATE POLICY "orders_admin_update" ON public.orders
  FOR UPDATE USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Order items: admins can read (for order details)
DROP POLICY IF EXISTS "order_items_admin_select" ON public.order_items;
CREATE POLICY "order_items_admin_select" ON public.order_items
  FOR SELECT USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Storage: allow admins to upload/update in product-images bucket (upsert needs SELECT + INSERT + UPDATE)
DROP POLICY IF EXISTS "product_images_admin_select" ON storage.objects;
DROP POLICY IF EXISTS "product_images_admin_insert" ON storage.objects;
DROP POLICY IF EXISTS "product_images_admin_update" ON storage.objects;
CREATE POLICY "product_images_admin_select" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'product-images'
    AND EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid())
  );
CREATE POLICY "product_images_admin_insert" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'product-images'
    AND EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid())
  );
CREATE POLICY "product_images_admin_update" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'product-images'
    AND EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid())
  );

-- Helper: add an admin by email (run this AFTER creating the user in Authentication → Users).
-- In SQL Editor run:  SELECT add_admin_by_email('your@email.com');
-- If you see "No user found", create the user first: Authentication → Users → Add user (email + password).
CREATE OR REPLACE FUNCTION public.add_admin_by_email(admin_email text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid;
BEGIN
  SELECT id INTO uid FROM auth.users WHERE email = admin_email LIMIT 1;
  IF uid IS NULL THEN
    RETURN 'No user with email ''' || admin_email || '''. Create them first: Authentication → Users → Add user (email + password), then run this again.';
  END IF;
  INSERT INTO public.admin_users (user_id) VALUES (uid) ON CONFLICT (user_id) DO NOTHING;
  RETURN 'Admin added: ' || admin_email || '. You can now log in to the admin panel.';
END;
$$;
