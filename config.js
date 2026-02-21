// Replace with your Supabase and Paystack credentials.
// For production, use environment variables or a backend to avoid exposing keys.
window.CRYPVILLA_CONFIG = {
  SUPABASE_URL: 'https://uucpwlklqacgfywyfcht.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1Y3B3bGtscWFjZ2Z5d3lmY2h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1MDEzNTgsImV4cCI6MjA4NzA3NzM1OH0.UkfafzIoB-5u4_6Lg4eyP3KAGGc1FHI8UxsO-oOixBU',
  PAYSTACK_PUBLIC_KEY: 'pk_test_fd4a676f6204bb33c511ad709071f7c9575daef9',  // Test key first; switch to pk_live_... for live payments
  FREE_SHIPPING_THRESHOLD: 500000,  // Free delivery in Lagos only, above this amount
  SHIPPING_FEE: 5000
};
