# Supabase setup for Crypvilla

1. Create a project at [supabase.com](https://supabase.com).
2. In **SQL Editor**, run the contents of `schema.sql`.
3. **Create the product-images bucket** (required for admin image uploads):
   - Go to **Storage** in the left sidebar.
   - Click **New bucket**.
   - **Name:** `product-images` (must be exactly this).
   - Turn **Public bucket** ON (so product image URLs work on the shop).
   - Click **Create bucket**.
   - *(Alternatively, run `create-product-images-bucket.sql` in the SQL Editor.)*
4. In **Project Settings → API**, copy **Project URL** and **anon public** key into `config.js` in the project root.

To add products, use the Table Editor or run INSERTs. Product images should be uploaded to the `product-images` bucket; use the public URL in `products.image_url`.
