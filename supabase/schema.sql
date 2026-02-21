-- Crypvilla E-commerce: Run this in Supabase SQL Editor after creating your project.
-- Also create a Storage bucket named "product-images" (public) in Supabase Dashboard.

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Products
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  price NUMERIC(12, 2) NOT NULL,
  compare_at_price NUMERIC(12, 2),
  image_url TEXT,
  images JSONB DEFAULT '[]',
  specs JSONB DEFAULT '{}',
  stock INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(category_id, slug)
);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  customer_email TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  delivery_address TEXT NOT NULL,
  subtotal NUMERIC(12, 2) NOT NULL,
  shipping NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total NUMERIC(12, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  paystack_reference TEXT,
  paystack_status TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Order items
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_snapshot JSONB NOT NULL,
  quantity INT NOT NULL,
  price NUMERIC(12, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);
CREATE INDEX IF NOT EXISTS idx_orders_email ON orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_orders_number ON orders(order_number);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Public read categories and products (drop first so script is re-runnable)
DROP POLICY IF EXISTS "categories_select" ON categories;
CREATE POLICY "categories_select" ON categories FOR SELECT USING (true);
DROP POLICY IF EXISTS "products_select" ON products;
CREATE POLICY "products_select" ON products FOR SELECT USING (true);

-- Anyone can insert orders and order_items (guest checkout)
DROP POLICY IF EXISTS "orders_insert" ON orders;
CREATE POLICY "orders_insert" ON orders FOR INSERT WITH CHECK (true);
-- Anon must be able to SELECT orders so insert().select('id') returns the new row for order_items
DROP POLICY IF EXISTS "orders_select_anon" ON orders;
CREATE POLICY "orders_select_anon" ON orders FOR SELECT USING (true);
DROP POLICY IF EXISTS "order_items_insert" ON order_items;
CREATE POLICY "order_items_insert" ON order_items FOR INSERT WITH CHECK (true);

-- Decrement product stock when an order item is inserted (after successful payment)
CREATE OR REPLACE FUNCTION public.decrement_product_stock_on_order_item()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.product_id IS NOT NULL AND NEW.quantity IS NOT NULL AND NEW.quantity > 0 THEN
    UPDATE products
    SET stock = GREATEST(0, stock - NEW.quantity),
        updated_at = now()
    WHERE id = NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trigger_decrement_stock_on_order_item ON order_items;
CREATE TRIGGER trigger_decrement_stock_on_order_item
  AFTER INSERT ON order_items
  FOR EACH ROW
  EXECUTE PROCEDURE public.decrement_product_stock_on_order_item();

-- Optional: allow users to read their own orders by email (for future "view my orders")
-- CREATE POLICY "orders_select_own" ON orders FOR SELECT USING (auth.jwt() ->> 'email' = customer_email);

-- Seed categories
INSERT INTO categories (slug, name, description, sort_order) VALUES
  ('grade-a-uk-used-laptops', 'Grade A UK Used Laptops', 'Quality refurbished laptops from the UK.', 1),
  ('brand-new-laptops', 'Brand New Laptops', 'Brand new laptops with warranty.', 2),
  ('laptop-accessories', 'Laptop Accessories', 'Bags, stands, adapters and more.', 3),
  ('uk-used-desktops', 'UK Used Desktops', 'Refurbished desktop PCs from the UK.', 4),
  ('brand-new-desktops', 'Brand New Desktops', 'Brand new desktops and components.', 5),
  ('all-in-ones', 'All-in-Ones', 'All-in-one PCs and monitors.', 6)
ON CONFLICT (slug) DO NOTHING;
