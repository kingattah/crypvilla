// Admin uses the same Supabase project and ANON key as the main site (no secret key in the browser).
// You must be logged in as an admin user; run supabase/schema-admin-auth.sql and add your user to admin_users.
window.CRYPVILLA_ADMIN_CONFIG = {
  SUPABASE_URL: 'https://uucpwlklqacgfywyfcht.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1Y3B3bGtscWFjZ2Z5d3lmY2h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1MDEzNTgsImV4cCI6MjA4NzA3NzM1OH0.UkfafzIoB-5u4_6Lg4eyP3KAGGc1FHI8UxsO-oOixBU',
  PAYSTACK_PUBLIC_KEY: 'pk_test_fd4a676f6204bb33c511ad709071f7c9575daef9',  // Test key; use same as config.js
  STORAGE_BUCKET: 'product-images'
};
