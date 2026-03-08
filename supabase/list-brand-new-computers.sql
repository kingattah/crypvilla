-- Crypvilla: List all brand new computers (laptops + desktops) with name and current price.
-- Run in Supabase SQL Editor.

SELECT
  p.name,
  p.price
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE c.slug IN ('brand-new-laptops', 'brand-new-desktops')
ORDER BY c.slug, p.name;
