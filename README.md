# Crypvilla E-commerce

E-commerce site for laptops, desktops, and accessories. Uses Supabase for data and storage, and Paystack for payments. No login required—checkout with email and delivery details only.

## Setup

1. **Supabase**  
   - Create a project at [supabase.com](https://supabase.com).  
   - Run the SQL in `supabase/schema.sql` in the SQL Editor.  
   - Create a **Storage** bucket named `product-images` (public).  
   - Copy **Project URL** and **anon** key from Project Settings > API.

2. **Config**  
   - Edit `config.js`: set `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and optionally `PAYSTACK_PUBLIC_KEY` (from [Paystack](https://paystack.com)). Use `pk_test_...` for test mode, `pk_live_...` for live.

3. **Run**  
   - Open `index.html` in a browser or serve the folder with any static server (e.g. `npx serve .`).

## Pages

- **index.html** — Landing and category links; optional featured products from Supabase.
- **shop.html** — Product grid and category filter; Add to cart.
- **product.html** — Single product (`?id=...` or `?slug=...`); Add to cart.
- **cart.html** — Cart with quantity and remove; subtotal and shipping (free in Lagos over ₦500,000).
- **checkout.html** — Delivery form and Pay with Paystack; order saved to Supabase on success.

## Categories (from schema)

Grade A UK Used Laptops, Brand New Laptops, Laptop Accessories, UK Used Desktops, Brand New Desktops, All-in-Ones.

## Admin panel

The **admin** folder uses the **same Supabase URL and anon key** as the main site (no secret key in the browser). You sign in with a Supabase Auth account that is listed in `admin_users`.

1. **One-time setup**  
   - In Supabase: **Authentication → Providers** — enable **Email**.  
   - Run the SQL in `supabase/schema-admin-auth.sql` in the SQL Editor (creates `admin_users` and RLS so admins can manage products, orders, storage).  
   - Create an admin user: **Authentication → Users → Add user** (email + password). Copy the user’s **UUID**.  
   - In SQL Editor: `INSERT INTO public.admin_users (user_id) VALUES ('paste-uuid-here');`

2. **Admin config**  
   - Edit `admin/config.js`: set `SUPABASE_URL` and `SUPABASE_ANON_KEY` (same as in the root `config.js`). No service_role key.

3. **What you can do**  
   - **Sign in** — Email + password (your admin user).  
   - **Dashboard** — Counts and “Test Supabase connection”.  
   - **Products** — Add, edit, delete; upload images to `product-images`.  
   - **Orders** — List, view details, update status.  
   - **Customers** — List derived from orders.

4. **Open admin**  
   - Open `admin/index.html` (or `/admin/` when serving the site). Sign in with your admin email and password.

## Adding products (via Admin or manually)

Add rows to the `products` table (and upload images to the `product-images` bucket). Required: `category_id`, `name`, `slug`, `price`. Optional: `compare_at_price` (for sale badge), `image_url`, `description`, `specs` (JSON, e.g. `{"processor":"Intel i5","ram":"8GB","storage":"256GB SSD"}`). You can do this from the Admin panel (Products → Add product) or directly in Supabase.
