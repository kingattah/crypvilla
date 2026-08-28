-- Crypvilla: Solar category + sample products for the shop and solar calculator.
-- Run this in the Supabase SQL Editor. Safe to re-run: inserts skip existing slugs, then images are updated.
-- Product photos live in /images/solar/ (inverter, panels, batteries, power stations, MC4 cables).
-- Calculator matching uses specs.kind plus watts / kva / capacity_wh / voltage / cable_mm2.

INSERT INTO categories (slug, name, description, sort_order) VALUES
  ('solar', 'Solar', 'Solar panels, inverters, batteries, power stations, and cables for home backup.', 9)
ON CONFLICT (slug) DO NOTHING;

-- ========== PANELS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '200W Monocrystalline Solar Panel',
  '200w-mono-solar-panel',
  '200W monocrystalline panel for small home and backup systems. Sample listing — confirm live stock and price in Admin.',
  85000, 1000,
  '/images/solar/panel-portable.jpg',
  '["/images/solar/panel-portable.jpg"]'::jsonb,
  '{"kind":"panel","watts":200,"label":"200W Mono"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '400W Monocrystalline Solar Panel',
  '400w-mono-solar-panel',
  '400W monocrystalline panel for residential rooftop arrays. Sample listing — confirm live stock and price in Admin.',
  145000, 1000,
  '/images/solar/panel-closeup.jpg',
  '["/images/solar/panel-closeup.jpg"]'::jsonb,
  '{"kind":"panel","watts":400,"label":"400W Mono"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '550W Monocrystalline Solar Panel',
  '550w-mono-solar-panel',
  'High-efficiency 550W monocrystalline panel. Sample listing — confirm live stock and price in Admin.',
  185000, 1000,
  '/images/solar/panel-array.jpg',
  '["/images/solar/panel-array.jpg"]'::jsonb,
  '{"kind":"panel","watts":550,"label":"550W Mono"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

-- ========== INVERTERS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '1.5 kVA Pure Sine Wave Inverter',
  '1-5kva-pure-sine-inverter',
  '1.5 kVA inverter for lights, fans, TV and fridge. Sample listing — confirm live stock and price in Admin.',
  185000, 1000,
  '/images/solar/inverter.jpg',
  '["/images/solar/inverter.jpg"]'::jsonb,
  '{"kind":"inverter","kva":1.5,"label":"1.5 kVA"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '2.5 kVA Pure Sine Wave Inverter',
  '2-5kva-pure-sine-inverter',
  '2.5 kVA inverter for a typical 1–2 bedroom backup setup. Sample listing — confirm live stock and price in Admin.',
  285000, 1000,
  '/images/solar/inverter.jpg',
  '["/images/solar/inverter.jpg"]'::jsonb,
  '{"kind":"inverter","kva":2.5,"label":"2.5 kVA"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '3.5 kVA Hybrid Inverter',
  '3-5kva-hybrid-inverter',
  '3.5 kVA hybrid inverter for home solar + backup. Sample listing — confirm live stock and price in Admin.',
  385000, 1000,
  '/images/solar/inverter.jpg',
  '["/images/solar/inverter.jpg"]'::jsonb,
  '{"kind":"inverter","kva":3.5,"label":"3.5 kVA"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '5 kVA Hybrid Inverter',
  '5kva-hybrid-inverter',
  '5 kVA hybrid inverter for larger homes and AC loads. Sample listing — confirm live stock and price in Admin.',
  550000, 1000,
  '/images/solar/inverter.jpg',
  '["/images/solar/inverter.jpg"]'::jsonb,
  '{"kind":"inverter","kva":5,"label":"5 kVA"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

-- ========== BATTERIES ==========
INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '12V 200Ah Tubular Battery',
  '12v-200ah-tubular-battery',
  '12V 200Ah (~2.4 kWh) tubular battery for inverter backup. Sample listing — confirm live stock and price in Admin.',
  195000, 1000,
  '/images/solar/battery.jpg',
  '["/images/solar/battery.jpg"]'::jsonb,
  '{"kind":"battery","capacity_wh":2400,"voltage":12,"label":"12V 200Ah"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '5 kWh Lithium Battery (24V)',
  '5kwh-lithium-battery-24v',
  'About 5 kWh lithium battery for home solar backup. Sample listing — confirm live stock and price in Admin.',
  1450000, 1000,
  '/images/solar/battery.jpg',
  '["/images/solar/battery.jpg"]'::jsonb,
  '{"kind":"battery","capacity_wh":5120,"voltage":24,"label":"5.1 kWh Li"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '10 kWh Lithium Battery (48V)',
  '10kwh-lithium-battery-48v',
  'About 10 kWh lithium battery for whole-home backup. Sample listing — confirm live stock and price in Admin.',
  2650000, 1000,
  '/images/solar/battery.jpg',
  '["/images/solar/battery.jpg"]'::jsonb,
  '{"kind":"battery","capacity_wh":10240,"voltage":48,"label":"10.2 kWh Li"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

-- ========== POWER STATIONS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '500Wh Portable Power Station',
  '500wh-portable-power-station',
  'Compact ~500Wh power station for phones, lights, and a laptop. Sample listing — confirm live stock and price in Admin.',
  285000, 1000,
  '/images/solar/powerstation-500.jpg',
  '["/images/solar/powerstation-500.jpg"]'::jsonb,
  '{"kind":"powerstation","capacity_wh":500,"watts":300,"label":"500Wh"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '1000Wh Portable Power Station',
  '1000wh-portable-power-station',
  'About 1000Wh portable power station for camping and small backup. Sample listing — confirm live stock and price in Admin.',
  485000, 1000,
  '/images/solar/powerstation-1000.jpg',
  '["/images/solar/powerstation-1000.jpg"]'::jsonb,
  '{"kind":"powerstation","capacity_wh":1000,"watts":600,"label":"1000Wh"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

-- ========== CABLES ==========
INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '6mm² Solar DC Cable Kit (10m)',
  '6mm2-solar-dc-cable-10m',
  '10m 6mm² DC cable kit for panels and inverter. Sample listing — confirm live stock and price in Admin.',
  18000, 1000,
  '/images/solar/cable.jpg',
  '["/images/solar/cable.jpg"]'::jsonb,
  '{"kind":"cable","cable_mm2":6,"label":"6 mm²"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

INSERT INTO products (category_id, name, slug, description, price, stock, image_url, images, specs)
SELECT id,
  '10mm² Solar DC Cable Kit (10m)',
  '10mm2-solar-dc-cable-10m',
  '10m 10mm² DC cable kit for higher-current battery and inverter runs. Sample listing — confirm live stock and price in Admin.',
  28000, 1000,
  '/images/solar/cable.jpg',
  '["/images/solar/cable.jpg"]'::jsonb,
  '{"kind":"cable","cable_mm2":10,"label":"10 mm²"}'::jsonb
FROM categories WHERE slug = 'solar'
ON CONFLICT (category_id, slug) DO NOTHING;

-- If you already ran an earlier version, this updates the wrong Unsplash placeholders.
UPDATE products p
SET image_url = v.url,
    images = jsonb_build_array(v.url)
FROM categories c,
LATERAL (VALUES
  ('200w-mono-solar-panel', '/images/solar/panel-portable.jpg'),
  ('400w-mono-solar-panel', '/images/solar/panel-closeup.jpg'),
  ('550w-mono-solar-panel', '/images/solar/panel-array.jpg'),
  ('1-5kva-pure-sine-inverter', '/images/solar/inverter.jpg'),
  ('2-5kva-pure-sine-inverter', '/images/solar/inverter.jpg'),
  ('3-5kva-hybrid-inverter', '/images/solar/inverter.jpg'),
  ('5kva-hybrid-inverter', '/images/solar/inverter.jpg'),
  ('12v-200ah-tubular-battery', '/images/solar/battery.jpg'),
  ('5kwh-lithium-battery-24v', '/images/solar/battery.jpg'),
  ('10kwh-lithium-battery-48v', '/images/solar/battery.jpg'),
  ('500wh-portable-power-station', '/images/solar/powerstation-500.jpg'),
  ('1000wh-portable-power-station', '/images/solar/powerstation-1000.jpg'),
  ('6mm2-solar-dc-cable-10m', '/images/solar/cable.jpg'),
  ('10mm2-solar-dc-cable-10m', '/images/solar/cable.jpg')
) AS v(slug, url)
WHERE p.category_id = c.id
  AND c.slug = 'solar'
  AND p.slug = v.slug;
