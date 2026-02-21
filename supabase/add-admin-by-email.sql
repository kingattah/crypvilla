-- ============================================================
-- ADD YOUR FIRST ADMIN (run in Supabase SQL Editor)
-- ============================================================
-- ORDER MATTERS:
--
-- 1. Run "schema-admin-auth.sql" first (if you haven't already).
-- 2. In Supabase: Authentication → Users → "Add user" → create user with
--    your email and password. Click "Create user".
-- 3. Then run the two blocks below in order.
-- ============================================================

-- Block 1: Create the helper function (run once)
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
    RETURN 'No user with email ''' || admin_email || '''. Create them first: Authentication → Users → Add user (email + password), then run Block 2 again.';
  END IF;
  INSERT INTO public.admin_users (user_id) VALUES (uid) ON CONFLICT (user_id) DO NOTHING;
  RETURN 'Admin added: ' || admin_email || '. You can now log in to the admin panel.';
END;
$$;

-- Block 2: Add your admin (replace with your email, then run)
-- You should see one row with message "Admin added: your@email.com ..." or "No user with email ..."
SELECT add_admin_by_email('neiyeattah@gmail.com');
