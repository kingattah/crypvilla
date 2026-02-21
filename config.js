// Replace with your Supabase and Paystack credentials.
// For production, use environment variables or a backend to avoid exposing keys.
window.CRYPVILLA_CONFIG = {
  SUPABASE_URL: 'https://uucpwlklqacgfywyfcht.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1Y3B3bGtscWFjZ2Z5d3lmY2h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1MDEzNTgsImV4cCI6MjA4NzA3NzM1OH0.UkfafzIoB-5u4_6Lg4eyP3KAGGc1FHI8UxsO-oOixBU',
  PAYSTACK_PUBLIC_KEY: 'pk_test_fd4a676f6204bb33c511ad709071f7c9575daef9',  // Test key first; switch to pk_live_... for live payments
  // Shipping: Lagos vs Outside Lagos; laptops vs accessories
  FREE_SHIPPING_THRESHOLD: 500000,   // Free in Lagos when order total >= this
  FREE_LAPTOP_COUNT: 4,              // Free delivery when buying 4+ laptops (any location)
  SHIPPING_LAGOS_ACCESSORIES: 5000,  // Laptop accessories in Lagos
  SHIPPING_OUTSIDE_ACCESSORIES: 8000,
  SHIPPING_LAGOS_LAPTOP: 8000,       // Laptops (below threshold) in Lagos
  SHIPPING_OUTSIDE_LAPTOP: 22000,
  // Category slugs used for shipping rules (laptops get laptop rate; laptop-accessories gets accessories rate)
  LAPTOP_CATEGORY_SLUGS: ['grade-a-uk-used-laptops', 'brand-new-laptops'],
  ACCESSORIES_CATEGORY_SLUG: 'laptop-accessories'
};
