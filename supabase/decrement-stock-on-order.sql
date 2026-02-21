-- Decrement product stock when an order item is inserted (e.g. after successful Paystack payment).
-- For existing projects: run this once in Supabase Dashboard → SQL Editor.
-- New installs: this is already included in schema.sql.

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
