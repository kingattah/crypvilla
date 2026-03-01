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

---

## Payment security (required before accepting real orders)

Orders are created only after **server-side Paystack verification** via Edge Functions. Do the following once:

### 1. Deploy Edge Functions

- In the Supabase Dashboard go to **Edge Functions**.
- Create two functions (or deploy via CLI from the project root):
  - **verify-and-create-order** — paste/deploy the code from `functions/verify-and-create-order/index.ts`.
  - **verify-and-complete-offer** — paste/deploy the code from `functions/verify-and-complete-offer/index.ts`.

If using the Supabase CLI from the repo root:

```bash
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy verify-and-create-order
supabase functions deploy verify-and-complete-offer
```

### 2. Set Paystack secret key

- In the Dashboard go to **Edge Functions** → **Secrets** (or **Project Settings** → **Edge Functions**).
- Add secret: **Name** `PAYSTACK_SECRET_KEY`, **Value** your Paystack secret key (e.g. `sk_live_...` or `sk_test_...`).
- Never put the secret in frontend code or in the repo.

### 3. Run the security migration

- In **SQL Editor**, run the contents of `security-fix-rls-and-offer-rpc.sql`.

### 4. CORS and testing

- The Edge Functions return CORS headers so the browser can call them from your site.
- **Do not open `checkout.html` directly from disk** (`file://`). The browser will send `origin: null`, which can cause CORS or security issues. Test using a real origin: e.g. **GitHub Pages** (your live site) or a local server (`npx serve .` or `python -m http.server`).
- This removes public read/insert on `orders` and `order_items`, and restricts `complete_offer_payment` to the service role (used by the Edge Functions). Admins keep access via existing RLS policies.
