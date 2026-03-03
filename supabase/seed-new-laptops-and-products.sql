-- Crypvilla: Seed new laptops, desktops, all-in-ones, monitors, printers, and accessories.
-- Run this in Supabase SQL Editor. Images can be added later via Admin.
-- Adds categories "monitors" and "printers" if missing.

INSERT INTO categories (slug, name, description, sort_order) VALUES
  ('monitors', 'Monitors', 'Desktop and display monitors.', 7),
  ('printers', 'Printers', 'Printers and all-in-one printers.', 8)
ON CONFLICT (slug) DO NOTHING;

-- Helper: insert product into a category by slug (no image; upload later)
-- Using INSERT ... SELECT so we don't need category UUIDs in the file.

-- ========== MICROSOFT – Brand New Laptops ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Microsoft Surface Laptop 7th Edition (Black)', 'microsoft-surface-laptop-7-black-zpg-00037',
  'Qualcomm Snapdragon X Elite (12-Core). GPU: X1E-78-100 3.4GHz. 512GB SSD. 16GB LPDDR5x. Qualcomm Adreno integrated graphics. Backlit keyboard, face recognition, ambient color sensor. Webcam, Bluetooth 5.4, Wi‑Fi 7. 13.8" PixelSense Flow touchscreen. 39W AC adapter. Windows 11 Home. Color: Black.',
  2053000, 1, '{"processor":"Qualcomm Snapdragon X Elite (12-Core)","ram":"16GB LPDDR5x","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Microsoft Surface Laptop 7th Edition (Platinum)', 'microsoft-surface-laptop-7-platinum-zpg-00001',
  'Qualcomm Snapdragon X Elite (12-Core). GPU: X1E-78-100 3.4GHz. 512GB SSD. 16GB LPDDR5x. Qualcomm Adreno integrated graphics. Backlit keyboard, face recognition, ambient color sensor. Webcam, Bluetooth 5.4, Wi‑Fi 7. 13.8" PixelSense Flow touchscreen. 39W AC adapter. Windows 11 Home. Color: Platinum.',
  2039000, 1, '{"processor":"Qualcomm Snapdragon X Elite (12-Core)","ram":"16GB LPDDR5x","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Microsoft Surface Laptop 7th Edition (Dune)', 'microsoft-surface-laptop-7-dune-zpg-00026',
  'Qualcomm Snapdragon X Elite (12-Core). GPU: X1E-78-100 3.4GHz. 512GB SSD. 16GB LPDDR5x. Qualcomm Adreno integrated graphics. Backlit keyboard, face recognition, ambient color sensor. Webcam, Bluetooth 5.4, Wi‑Fi 7. 13.8" PixelSense Flow touchscreen. 39W AC adapter. Windows 11 Home. Color: Dune.',
  2076000, 1, '{"processor":"Qualcomm Snapdragon X Elite (12-Core)","ram":"16GB LPDDR5x","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Microsoft Surface Pro Copilot+ PC 11th Edition Bundle (Black + Keyboard)', 'microsoft-surface-pro-11-bundle-90nl5m100s00',
  '13" OLED Touchscreen 2880 x 1920. Snapdragon X Elite. 16GB RAM. 1TB SSD. Windows 11 Home. Black. Includes Surface Pro English Keyboard.',
  2534000, 1, '{"processor":"Snapdragon X Elite","ram":"16GB","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Microsoft Surface Pro Copilot+ PC 11th Edition Bundle (Black + Keyboard + Slim Pen)', 'microsoft-surface-pro-11-bundle-slim-pen-90nl5m101cf0',
  '13" OLED Touchscreen 2880 x 1920. Snapdragon X Elite. 16GB RAM. 1TB SSD. Windows 11 Home. Black. Surface Pro English Keyboard with Slim Pen.',
  2684000, 1, '{"processor":"Snapdragon X Elite","ram":"16GB","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== HP LAPTOPS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Laptop 15-fd0230wm (Silver)', 'hp-15-fd0230wm-c68gjua',
  'Intel Core i3-N305 up to 3.8GHz. 13th Gen. 512GB SSD. 8GB DDR5. Touchscreen. Intel Iris Xe. Webcam, Bluetooth, Wi‑Fi. 15.6" FHD IPS. 3-cell 41Wh. Windows 11. Color: Silver.',
  505000, 1, '{"processor":"Intel Core i3-N305 (13th Gen)","ram":"8GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Laptop 15-fd0154wm (Silver)', 'hp-15-fd0154wm-bz1w9ua',
  'Intel Core Ultra 5 125H up to 4.6GHz. 14th Gen. 512GB SSD. 8GB DDR5. Touchscreen. Intel Iris Xe. Webcam, Bluetooth, Wi‑Fi. 15.6" FHD IPS. 3-cell 41Wh. Windows 11. Color: Silver.',
  677000, 1, '{"processor":"Intel Core Ultra 5 125H (14th Gen)","ram":"8GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 255 G10 (Turbo Silver)', 'hp-255-g10-8a548ea',
  'AMD Ryzen 7 up to 4.5GHz. 13th Gen. 512GB SSD. 16GB DDR4. Backlit keyboard, fingerprint reader. AMD Radeon integrated. Webcam, Bluetooth, Wi‑Fi. 15.6" FHD IPS. 3-cell 41Wh. FreeDOS. Color: Turbo Silver.',
  709000, 1, '{"processor":"AMD Ryzen 7","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP OmniBook 5 Flip Laptop (Silver)', 'hp-omnibook-5-flip-14-fp0023dx-b86q7ua',
  'Intel Core 7 up to 5.4GHz Turbo. 15th Gen. 512GB SSD. 16GB onboard DDR5. Intel Iris Xe. Touchscreen, backlit keyboard. HP 5MP IR camera. 4-cell 68Wh. 14" FHD IPS. Windows 11 Home. Color: Silver.',
  929000, 1, '{"processor":"Intel Core 7 (15th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP OmniBook 5 Laptop AI (Silver)', 'hp-omnibook-5-16-af1017wm-b5px1ua',
  'Intel Core Ultra 7 255U up to 5.4GHz. 15th Gen. 1TB SSD. 16GB onboard DDR5. Intel Iris Xe. Touchscreen, backlit keyboard. HP IR camera. 3-cell 59Wh. 16" 2K (1920x1200) IPS. Windows 11 Home. Color: Silver.',
  1033000, 1, '{"processor":"Intel Core Ultra 7 255U (15th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP OmniBook Ultra Flip Laptop (Atmospheric Blue)', 'hp-omnibook-ultra-flip-14-fh0047nr-aa3b6ua',
  'Intel Core Ultra 7 256V up to 4.8GHz. 15th Gen. 1TB SSD. 16GB onboard DDR5. Touchscreen, backlit keyboard, fingerprint reader. HP 9MP IR AI camera, Poly Studio. 6-cell 64Wh. 14" 3K (2880x1800) UWVA OLED. Windows 11 Home. Color: Atmospheric Blue. No pen included.',
  1950000, 1, '{"processor":"Intel Core Ultra 7 256V (15th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP OmniBook Ultra Flip Laptop Next Gen AI (Atmospheric Blue + Pen)', 'hp-omnibook-ultra-flip-next-gen-14-fh00nr-9f2b9av',
  'Intel Core Ultra 7 258V up to 4.8GHz. 15th Gen. 1TB SSD. 32GB onboard DDR5. Touchscreen, backlit keyboard, fingerprint reader. Rechargeable MPP2.0 Tilt Pen. HP 9MP IR AI camera, Poly Studio. 6-cell 64Wh. 14" 3K UWVA OLED. Windows 11 Home. Color: Atmospheric Blue.',
  2300000, 1, '{"processor":"Intel Core Ultra 7 258V (15th Gen)","ram":"32GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP OmniBook Ultra Flip Laptop Next Gen AI (Gray)', 'hp-omnibook-ultra-flip-14-fh0033dx-aw5z6ua',
  'Intel Core Ultra 9 288V up to 5.4GHz. 15th Gen. 2TB SSD. 32GB onboard DDR5. Touchscreen, backlit keyboard, fingerprint reader. HP 9MP IR AI camera, Poly Studio. 6-cell 64Wh. 14" 3K UWVA OLED. Windows 11 Home. Color: Gray.',
  2382000, 1, '{"processor":"Intel Core Ultra 9 288V (15th Gen)","ram":"32GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Pavilion 14 x360 Convertible (Silver)', 'hp-pavilion-14-x360-14t-ek200-8x328av2',
  'Intel Core Ultra 7 up to 5.4GHz. 14th Gen. 1TB SSD. 16GB onboard DDR4. Intel Iris Xe. Touchscreen, stylus pen. Webcam, Bluetooth, Wi‑Fi. 3-cell 43Wh. 14" FHD IPS. Windows 11 Home. Color: Silver.',
  1380000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"16GB DDR4","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP ProBook 440 G10 (Silver)', 'hp-probook-440-g10-968j2et',
  '13th Gen Intel Core i5 up to 4.7GHz. 512GB SSD. 16GB DDR4. Intel Iris Xe. Backlit keyboard, fingerprint reader. Webcam, Bluetooth, Wi‑Fi. 14" FHD IPS. FreeDOS. Color: Silver.',
  855000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP ProBook 450 G10 (Silver)', 'hp-probook-450-g10-85c43ea',
  'Intel Core i5 up to 4.7GHz. 13th Gen. 512GB SSD. 8GB DDR4. Touchscreen, backlit keyboard, fingerprint reader, numeric keyboard. Webcam, Bluetooth, Wi‑Fi. 15.6" FHD. FreeDOS. Color: Silver.',
  965000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP ProBook 440 G11 (Silver, FreeDOS)', 'hp-probook-440-g11-freedos-9g1w6et',
  '14th Gen Intel Core Ultra 7 155U up to 4.8GHz. 512GB SSD. 16GB DDR5. Intel Iris Xe. Backlit keyboard, fingerprint reader. 14" WUXGA (1920x1200). FreeDOS. Color: Silver.',
  1089000, 1, '{"processor":"Intel Core Ultra 7 155U (14th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP ProBook 440 G11 (Silver, Windows 11 Pro, 3yr warranty)', 'hp-probook-440-g11-windows-9g1w6et',
  '14th Gen Intel Core Ultra 7 155U up to 4.8GHz. 512GB SSD. 16GB DDR5. Intel Iris Xe. Backlit keyboard, fingerprint reader. 14" WUXGA. Windows 11 Pro. 3 years channel warranty. Color: Silver.',
  1199000, 1, '{"processor":"Intel Core Ultra 7 155U (14th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Envy 15 x360 Convertible (Silver)', 'hp-envy-15-x360-15-ew1058wm-85s59ua',
  'Intel Core i5 up to 5.0GHz. 13th Gen. 512GB SSD. 8GB onboard DDR4. Intel Iris Xe. Touchscreen, backlit keyboard. 3-cell 43Wh. 15.6" FHD IPS. Windows 11 Home. Color: Silver.',
  880000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Victus 15 Gaming (Silver)', 'hp-victus-15-gaming-b8ln4ua',
  'Intel Core i5 4.8GHz. 13th Gen. 512GB SSD. 16GB DDR4. 6GB NVIDIA RTX 4050. Backlit keyboard. 6-cell 83Wh. 15.6" FHD IPS. Windows 11. Color: Silver.',
  1050000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Victus 15 Gaming (Mica Grey)', 'hp-victus-15-gaming-c21tgea',
  'Intel Core i7 4.9GHz. 13th Gen. 512GB SSD. 16GB DDR4. 6GB NVIDIA RTX 3050. Backlit keyboard. 3-cell 52.5Wh. DTS X Ultra. 15.6" FHD IPS. Windows 11. Color: Mica Grey.',
  1350000, 1, '{"processor":"Intel Core i7 (13th Gen)","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen Transcend 14 Gaming (Shadow Black)', 'hp-omen-transcend-14-a08fvua',
  'Intel Core Ultra 7 up to 4.7GHz. 14th Gen. 2TB SSD. 16GB LPDDR5x. 8GB NVIDIA RTX 4060. Backlit keyboard, HyperX. 4-cell 70Wh. 14" 2.8K UWVA OLED. Windows 11. Color: Shadow Black.',
  2300000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"16GB LPDDR5x","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen Transcend 14 Gaming Ultra 9 (Shadow Black)', 'hp-omen-transcend-14-9q056ua',
  'Intel Core Ultra 9 up to 5.1GHz. 14th Gen. 2TB SSD. 32GB LPDDR5x. 8GB NVIDIA RTX 4070. Backlit keyboard, HyperX. 6-cell 71Wh. 14" 3K UWVA OLED. Windows 11. Color: Shadow Black.',
  3200000, 1, '{"processor":"Intel Core Ultra 9 (14th Gen)","ram":"32GB LPDDR5x","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen Transcend 14 Gaming 15th Gen (Shadow Black)', 'hp-omen-transcend-14-b93s3ua',
  'Intel Core Ultra 9 up to 5.1GHz. 15th Gen. 1TB SSD. 32GB LPDDR5x. 8GB NVIDIA RTX 5070. Backlit keyboard, HyperX. 6-cell 71Wh. 14" 3K UWVA OLED. Windows 11. Color: Shadow Black.',
  3300000, 1, '{"processor":"Intel Core Ultra 9 (15th Gen)","ram":"32GB LPDDR5x","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen 16 Gaming (Shadow Black)', 'hp-omen-16-bz4a3ua',
  'Intel Core Ultra 7 255H up to 5.4GHz. 15th Gen. 1TB SSD. 16GB DDR5. 8GB NVIDIA RTX 5060. RGB backlit keyboard. 4-cell 70Wh. 16" WQXGA FHD IPS. Windows 11. Color: Shadow Black.',
  1950000, 1, '{"processor":"Intel Core Ultra 7 255H (15th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen 16 Slim Gaming (Shadow Black)', 'hp-omen-16-slim-bm7b9ua',
  'Intel Core Ultra 9 285H up to 5.4GHz. 15th Gen. 1TB SSD. 16GB DDR5. 8GB NVIDIA RTX 5070. RGB backlit keyboard. 4-cell 70Wh. 16" WQXGA FHD IPS. Windows 11. Color: Shadow Black.',
  2480000, 1, '{"processor":"Intel Core Ultra 9 285H (15th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen 16 Slim Gaming 32GB (Shadow Black)', 'hp-omen-16-slim-az6j3av2',
  'Intel Core Ultra 9 285H up to 5.4GHz. 15th Gen. 1TB SSD. 32GB DDR5. 8GB NVIDIA RTX 5070. RGB backlit keyboard. 4-cell 70Wh. 16" WQXGA FHD IPS. Windows 11. Color: Shadow Black.',
  2770000, 1, '{"processor":"Intel Core Ultra 9 285H (15th Gen)","ram":"32GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Omen Max 16T-AH000 Gaming (Shadow Black)', 'hp-omen-max-16t-ah000-a4nq6av01',
  'Intel Core Ultra 9 275HX up to 5.4GHz. 15th Gen. 1TB SSD. 32GB DDR5. 24GB NVIDIA RTX 5090. RGB backlit keyboard. 4-cell 70Wh. 16" WQXGA (2560x1600) 60–240Hz. Windows 11. Color: Shadow Black.',
  5427000, 1, '{"processor":"Intel Core Ultra 9 275HX (15th Gen)","ram":"32GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP EliteBook 840 G11 (Silver)', 'hp-elitebook-840-g11-b1sb9up',
  '14th Gen Intel Core Ultra 5 125U up to 4.3GHz. 256GB SSD. 16GB DDR5. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 14" WUXGA IPS. Windows 11 Pro, Wolf Pro Security. Color: Silver.',
  1400000, 1, '{"processor":"Intel Core Ultra 5 125U (14th Gen)","ram":"16GB DDR5","storage":"256GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP EliteBook Ultra G1q AI (Silver)', 'hp-elitebook-ultra-g1q-ai-a4je4ut',
  '15th Gen Snapdragon X Elite X1E-78 12-core up to 3.4GHz. 512GB SSD. 16GB DDR5. Qualcomm Adreno integrated. Touchscreen, backlit keyboard, fingerprint reader. 5MP IR webcam. 14" 2.2K (2240x1400) IPS. Windows 11 Pro, Wolf Pro Security. Color: Silver.',
  1488000, 1, '{"processor":"Snapdragon X Elite X1E-78","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP EliteBook 830 G11 x360 (Silver)', 'hp-elitebook-830-g11-x360-a6su3t',
  '14th Gen Intel Core Ultra 7 up to 5.4GHz. 512GB SSD. 16GB DDR5. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 13.3" FHD IPS. Windows 11 Pro, Wolf Pro Security. Color: Silver.',
  1700000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP EliteBook X360 1040 G11 2-in-1 (Silver)', 'hp-elitebook-x360-1040-g11-a6sv3ut',
  '14th Gen Intel Core Ultra 7 up to 5.4GHz. 512GB SSD. 16GB DDR5. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader, stylus pen. 14" FHD IPS. Windows 11 Pro, Wolf Pro Security. Color: Silver.',
  2000000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== DELL LAPTOPS & DESKTOPS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Inspiron 15 3530 (Carbon Black)', 'dell-inspiron-15-3530-gkccm74',
  'Intel Core i5 up to 4.1GHz. 13th Gen. 512GB SSD. 8GB DDR4. Touchscreen, Intel UHD. Wireless AX, Bluetooth, SD card, HDMI, USB-C. 15.6" FHD touch. Windows 11 Home. Color: Carbon Black.',
  720000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Inspiron 14 7445 2-in-1 (Ice Blue)', 'dell-inspiron-14-7445-2in1-cthbgc4',
  'AMD Ryzen 5 8640HS up to 4.4GHz. 512GB SSD. 16GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD+ touch. Windows 11 Home. Color: Ice Blue.',
  797000, 1, '{"processor":"AMD Ryzen 5 8640HS","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Inspiron 14 7440 2-in-1 (Ice Blue)', 'dell-inspiron-14-7440-2in1-h2hbsb4',
  'Intel Core 5 120U up to 5.0GHz. 14th Gen. 512GB SSD. 16GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. Intel Iris Xe. 14" FHD+ touch. Windows 11 Home. Color: Ice Blue.',
  947000, 1, '{"processor":"Intel Core 5 120U (14th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell 16 (Silver)', 'dell-16-9fhjgc4',
  'Intel Core 5 120U up to 4.8GHz. 15th Gen. 512GB SSD. 8GB DDR5. Touchscreen, backlit keyboard. 16" FHD+ touch. Windows 11 Home. Color: Silver.',
  733000, 1, '{"processor":"Intel Core 5 120U (15th Gen)","ram":"8GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell 15 (Carbon Black)', 'dell-15-9w3sbd4',
  'Intel Core i7-1355U up to 4.8GHz. 13th Gen. 1TB SSD. 16GB DDR5. Touchscreen. 15.6" FHD+ touch. Windows 11 Home. Color: Carbon Black.',
  1022000, 1, '{"processor":"Intel Core i7-1355U (13th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Inspiron 16 Plus (Ice Blue)', 'dell-inspiron-16-plus-7y97g54',
  'Intel Core Ultra 9 185H up to 5.1GHz. 14th Gen. 2TB SSD. 32GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. Intel Arc graphics. 16" FHD+ touch. Windows 11 Home. Color: Ice Blue.',
  1599000, 1, '{"processor":"Intel Core Ultra 9 185H (14th Gen)","ram":"32GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Latitude 5450 (Silver)', 'dell-latitude-5450-9kx1lg4',
  'Intel Core Ultra 5 125U up to 4.3GHz. 14th Gen. 512GB SSD. 16GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD+ touch. Windows 11 Pro. Color: Silver.',
  1229000, 1, '{"processor":"Intel Core Ultra 5 125U (14th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Pro 14 Plus PB14250 (Silver)', 'dell-pro-14-plus-pb14250-1yqwjc4',
  'Intel Core Ultra 7 vPro 268V up to 5.0GHz. 15th Gen. 256GB SSD. 32GB onboard DDR5. Backlit keyboard. 14" FHD. Windows 11 Pro. Color: Silver.',
  1639000, 1, '{"processor":"Intel Core Ultra 7 268V (15th Gen)","ram":"32GB DDR5","storage":"256GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Alienware M18 Area-51 (Liquid Teal)', 'dell-alienware-m18-area51-bks20b4',
  'Intel Core Ultra 9 up to 5.4GHz Turbo. 15th Gen. 2TB SSD. 64GB DDR5. 16GB NVIDIA RTX 5080 GDDR7. Per-key AlienFX RGB keyboard. 6-cell 96Wh. 18" WQXGA OLED 4K. Windows 11 Home. Color: Liquid Teal.',
  5900000, 1, '{"processor":"Intel Core Ultra 9 (15th Gen)","ram":"64GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Alienware M18 Area-51 RTX 5090 (Liquid Teal)', 'dell-alienware-m18-area51-cy14sb4',
  'Intel Core Ultra 9 up to 5.4GHz Turbo. 15th Gen. 2TB SSD. 64GB (2x32) DDR5 6400MT/s. 24GB NVIDIA RTX 5090 GDDR7. Per-key AlienFX RGB. Wi‑Fi 7, Office 365 30-day trial. 6-cell 96Wh. 18" WQXGA OLED 4K, Comfort View Plus, FHD cam. Windows 11 Home. Color: Liquid Teal.',
  7050000, 1, '{"processor":"Intel Core Ultra 9 (15th Gen)","ram":"64GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell XPS 13 9350 1TB (Platinum)', 'dell-xps-13-9350-g5ctbd4',
  'Intel Core Ultra 7 258V up to 4.8GHz. 15th Gen. 1TB SSD. 32GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. 3-cell 55Wh. 13.4" OLED+ touch. Windows 11. Color: Platinum.',
  2644000, 1, '{"processor":"Intel Core Ultra 7 258V (15th Gen)","ram":"32GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell XPS 13 9350 2TB (Platinum)', 'dell-xps-13-9350-2tb-3vqxff4',
  'Intel Core Ultra 7 258V up to 4.8GHz. 15th Gen. 2TB SSD. 32GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. 3-cell 55Wh. 13.4" OLED+ touch. Windows 11. Color: Platinum.',
  2700000, 1, '{"processor":"Intel Core Ultra 7 258V (15th Gen)","ram":"32GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell 14 Premium DA14250 XPS Replacement (Platinum)', 'dell-14-premium-da14250-jvf68f4',
  'Intel Core Ultra 7 255H up to 5.1GHz. 15th Gen. 2TB SSD. 64GB LPDDR5X 8400MT/s. 6GB NVIDIA RTX 4050. Touchscreen, backlit keyboard, fingerprint reader. 6-cell 69.5Wh. 14.5" OLED+ touch. Windows 11 Pro. Color: Platinum.',
  4000000, 1, '{"processor":"Intel Core Ultra 7 255H (15th Gen)","ram":"64GB LPDDR5X","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell XPS 13 9350 Ultra 9 (Platinum)', 'dell-xps-13-9350-ultra9-jyj8vb4',
  'Intel Core Ultra 9 288V up to 5.1GHz. 15th Gen. 1TB SSD. 32GB DDR5. Touchscreen, backlit keyboard, fingerprint reader. 3-cell 55Wh. 13.4" UHD+ touch. Windows 11 Pro. Color: Platinum.',
  3000000, 1, '{"processor":"Intel Core Ultra 9 288V (15th Gen)","ram":"32GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== LENOVO LAPTOPS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo IdeaPad 5 2-in-1 14IRU9 (Cosmic Blue)', 'lenovo-ideapad-5-2in1-14iru9-83dt0002us',
  'Intel Core 5 120U up to 4.4GHz. 14th Gen. 512GB SSD. 8GB DDR4. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. Copilot+, stylus pen. 14" WUXGA FHD touch. Windows 11. Color: Cosmic Blue.',
  836000, 1, '{"processor":"Intel Core 5 120U (14th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo Yoga 7 16IML9 2-in-1 (Storm Grey)', 'lenovo-yoga-7-16iml9-2in1-83dl0002us',
  'Intel Core Ultra 7 155U up to 4.8GHz. 14th Gen. 1TB SSD. 16GB LPDDR5x. Intel integrated graphics. Touchscreen, backlit keyboard, fingerprint reader. 16" WUXGA IPS touch. Windows 11. Color: Storm Grey.',
  1207000, 1, '{"processor":"Intel Core Ultra 7 155U (14th Gen)","ram":"16GB LPDDR5x","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad X13 2-in-1 Gen 5 (Black)', 'lenovo-thinkpad-x13-2in1-gen5-21lw001tus',
  'Intel Core Ultra 7 up to 5.4GHz. 14th Gen. 1TB SSD. 16GB DDR5 onboard. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader, stylus pen. 13.3" FHD IPS. Windows 11 Pro. Color: Black.',
  1900000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad T14 Gen 4 (Black)', 'lenovo-thinkpad-t14-gen4-21hd0019au',
  'Intel Core i5 5.4GHz. 13th Gen. 512GB SSD. 16GB DDR4. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD IPS. Windows 11. Color: Black.',
  1450000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad T14 Gen 5 (Graphite)', 'lenovo-thinkpad-t14-gen5',
  'Intel Core Ultra 7 5.4GHz. 14th Gen. 1TB SSD. 32GB DDR4. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD IPS. Windows 11. Color: Graphite.',
  2100000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"32GB DDR4","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad X1 Carbon Gen 11 1TB (Black)', 'lenovo-thinkpad-x1-carbon-gen11-21hms4va00',
  'Intel Core i7 up to 5.4GHz. 13th Gen. 1TB SSD. 16GB DDR4. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD IPS. Windows 11 Pro. Color: Black.',
  1900000, 1, '{"processor":"Intel Core i7 (13th Gen)","ram":"16GB DDR4","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad X1 Carbon Gen 11 512GB (Black)', 'lenovo-thinkpad-x1-carbon-gen11-21hm000jus',
  'Intel Core i7 up to 5.4GHz. 13th Gen. 512GB SSD. 16GB DDR4. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD IPS. Windows 11 Pro. Color: Black.',
  1800000, 1, '{"processor":"Intel Core i7 (13th Gen)","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad X1 Carbon Gen 12 (Black)', 'lenovo-thinkpad-x1-carbon-gen12',
  'Intel Core Ultra 7 up to 5.4GHz. 14th Gen. 1TB SSD. 32GB DDR4. Intel Iris Xe. Touchscreen, backlit keyboard, fingerprint reader. 14" FHD IPS. Windows 11 Pro. Color: Black.',
  2350000, 1, '{"processor":"Intel Core Ultra 7 (14th Gen)","ram":"32GB DDR4","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad E14 Gen 7 Ultra 5 (Black)', 'lenovo-thinkpad-e14-gen7-ultra5',
  'Intel Core Ultra 5 4.8GHz. 15th Gen. 512GB SSD. 8GB DDR5. Intel Iris Xe. Backlit keyboard, fingerprint reader. 14" FHD IPS. FreeDOS. Color: Black.',
  1102000, 1, '{"processor":"Intel Core Ultra 5 (15th Gen)","ram":"8GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Lenovo ThinkPad E14 Gen 7 Ultra 7 (Black)', 'lenovo-thinkpad-e14-gen7-21sxs0n500',
  'Intel Core Ultra 7 5.4GHz. 15th Gen. 512GB SSD. 16GB DDR5. Intel Iris Xe. Backlit keyboard, fingerprint reader. 14" FHD IPS. FreeDOS. Color: Black.',
  1367000, 1, '{"processor":"Intel Core Ultra 7 (15th Gen)","ram":"16GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== ASUS LAPTOPS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'ASUS VivoBook 15 Pro (Blue)', 'asus-vivobook-15-pro-90nb0uv2-m00db0',
  '11th Gen Intel Core i5 2.4GHz up to 4.2GHz. 512GB SSD. 8GB DDR4. 4GB NVIDIA GTX 1650. 4-cell 42Wh. Keyboard light. 15.6" display. Windows 11. Color: Blue.',
  790000, 1, '{"processor":"Intel Core i5 (11th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'ASUS ROG Strix G615LR (Eclipse Gray)', 'asus-rog-strix-g615lr-90nr0lr1-m005h0',
  'Intel Core Ultra 9-275HX 2.7GHz up to 5.4GHz, 24 cores. 15th Gen. 2TB SSD. 32GB DDR5 onboard. 12GB NVIDIA RTX 5070 Ti. Backlit keyboard. 4-cell 90Wh. Wi‑Fi 7. 16" FHD+ WUXGA 2.5K. ROG Intelligent Cooling. Windows 11 Home. Color: Eclipse Gray.',
  5343000, 1, '{"processor":"Intel Core Ultra 9-275HX (15th Gen)","ram":"32GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'ASUS ROG Strix G615LW (Eclipse Gray)', 'asus-rog-strix-g615lw-90nr0lg1-m005p0',
  'Intel Core Ultra 9-275HX 2.7GHz up to 5.4GHz, 24 cores. 15th Gen. 2TB SSD. 64GB DDR5 onboard. 16GB NVIDIA RTX 5080. Backlit keyboard. 4-cell 90Wh. Wi‑Fi 7. 16" WQXGA 2.5K (2560x1600). ROG Intelligent Cooling. Windows 11 Home. Color: Eclipse Gray.',
  6227000, 1, '{"processor":"Intel Core Ultra 9-275HX (15th Gen)","ram":"64GB DDR5","storage":"2TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'ASUS ROG Strix Scar 18 (Off Black)', 'asus-rog-strix-scar-18-90nr0lf1-m007t0',
  'ASUS ROG Strix Scar G835LX. Intel Core Ultra 9-275HX 2.7GHz up to 5.4GHz, 24 cores. 15th Gen. 4TB SSD. 64GB DDR5 onboard. 24GB NVIDIA RTX 5090. Backlit keyboard. 4-cell 90Wh. Wi‑Fi 7. 18" WQXGA 2.5K (2560x1600). ROG Intelligent Cooling. Windows 11 Home. Color: Off Black.',
  7793000, 1, '{"processor":"Intel Core Ultra 9-275HX (15th Gen)","ram":"64GB DDR5","storage":"4TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'ASUS ZenBook Duo UX8406M (Inkwell Grey)', 'asus-zenbook-duo-ux8406m-90nb12u1-m007v0',
  'Intel Core Ultra 7-155H up to 5.8GHz. 14th Gen. 1TB SSD. 16GB DDR5 onboard. Touchscreen, backlit keyboard. 4-cell 75Wh. 14" OLED WQXGA 2.8K (2880x1620). Windows 11 Home. Color: Inkwell Grey.',
  2600000, 1, '{"processor":"Intel Core Ultra 7-155H (14th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== ACER LAPTOPS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Acer Predator Helios Neo 16 AI (Obsidian Black)', 'acer-predator-helios-neo-16-ai-phn16-73-97bp',
  'Intel Core Ultra 9 275HX up to 5.5GHz. 15th Gen. 1TB SSD. 16GB DDR5. RGB backlit keyboard. NVIDIA GeForce RTX 5060 8GB GDDR7. 90Wh battery. 16" 180Hz WQXGA IPS. No OS. Color: Obsidian Black.',
  2408000, 1, '{"processor":"Intel Core Ultra 9 275HX (15th Gen)","ram":"16GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Acer Predator Helios Neo 16S AI (Obsidian Black)', 'acer-predator-helios-neo-16s-ai-phn16s-71-98rf',
  'Intel Core Ultra 9 275HX up to 5.8GHz. 15th Gen. 1TB SSD. 32GB DDR5. RGB backlit keyboard. NVIDIA GeForce RTX 5070 Ti 12GB GDDR7. 76Wh battery. 16" 240Hz (2560x1600) 500 nits. Windows 11 Home. Color: Obsidian Black.',
  3158000, 1, '{"processor":"Intel Core Ultra 9 275HX (15th Gen)","ram":"32GB DDR5","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== MSI LAPTOP ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'MSI Cyborg 15 Laptop (Translucent Black)', 'msi-cyborg-15-a13uc-1291xae',
  'Intel Core i7 up to 5.0GHz. 13th Gen. 512GB SSD. 16GB DDR4. 4GB NVIDIA RTX 3050. Backlit keyboard. 15.6" FHD IPS. FreeDOS. Color: Translucent Black.',
  1380000, 1, '{"processor":"Intel Core i7 (13th Gen)","ram":"16GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-laptops' LIMIT 1;

-- ========== HP DESKTOPS (Brand New Desktops) ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Pro Tower 400 G9 Desktop with Monitor P24VG5 (Black)', 'hp-pro-tower-400-g9-p24vg5-99n19et',
  'Intel Core i3 up to 4.0GHz. 13th Gen. 256GB SSD. 8GB DDR4. DVD/CD drive. Keyboard and mouse. FreeDOS. Color: Black. Includes monitor.',
  709000, 1, '{"processor":"Intel Core i3 (13th Gen)","ram":"8GB DDR4","storage":"256GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-desktops' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Pro Tower 290 G9 Desktop with 22" Monitor Series 3 Pro 322PV (Black)', 'hp-pro-tower-290-g9-22-monitor-a55lvet',
  'Intel Core i5 up to 4.7GHz. 13th Gen. 512GB SSD. 8GB DDR4. Wireless LAN. Keyboard and mouse. FreeDOS. Color: Black. Includes 22" monitor.',
  849000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'brand-new-desktops' LIMIT 1;

-- ========== HP ALL-IN-ONES ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 22 DG-0007nh All-in-One (Starry White)', 'hp-22-dg-0007nh-b13ybea',
  'Intel Pentium N-series up to 3.4GHz. 256GB SSD. 8GB DDR5. Intel UHD graphics. 21.5" FHD. HP white wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Starry White.',
  520000, 1, '{"processor":"Intel Pentium N-series","ram":"8GB DDR5","storage":"256GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 22 DG-0012nh All-in-One (Cashmere White)', 'hp-22-dg-0012nh-a99bjea',
  'Intel Core i3 N-series up to 3.8GHz. 512GB SSD. 8GB DDR5. Intel UHD graphics. 21.5" FHD. HP white wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Cashmere White.',
  634000, 1, '{"processor":"Intel Core i3 N-series","ram":"8GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 22 DG-0013nh All-in-One (Black)', 'hp-22-dg-0013nh-a99bkea',
  'Intel Core i3 N-series up to 3.8GHz. 512GB SSD. 8GB DDR5. Intel UHD graphics. 21.5" FHD. HP black wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Black.',
  631000, 1, '{"processor":"Intel Core i3 N-series","ram":"8GB DDR5","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 24 CB-1288nh All-in-One (Starry White)', 'hp-24-cb-1288nh-b73txea',
  'Intel Core i3 up to 4.4GHz. 12th Gen. 512GB SSD. 8GB DDR4. 23.8" FHD. HP white wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Starry White.',
  674000, 1, '{"processor":"Intel Core i3 (12th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 24 CB-1287nh All-in-One (Black)', 'hp-24-cb-1287nh-b73twea',
  'Intel Core i3 up to 4.4GHz. 12th Gen. 512GB SSD. 8GB DDR4. 23.8" FHD. HP black wired keyboard and mouse. Bluetooth, Wi‑Fi, webcam. FreeDOS. Color: Black.',
  667000, 1, '{"processor":"Intel Core i3 (12th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 24 CR-0307NH All-in-One (Shell White)', 'hp-24-cr-0307nh-b73t8ea',
  'Intel Core i5 up to 4.6GHz. 13th Gen. 512GB SSD. 8GB DDR4. 23.8" FHD. HP white wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Shell White.',
  899000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"8GB DDR4","storage":"512GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Pro One 440 G9 All-in-One (Black)', 'hp-pro-one-440-g9-9j162pc',
  'Intel Core i5 up to 4.8GHz. 13th Gen. 256GB SSD. 16GB DDR4. 23.8" FHD. HP black wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Black.',
  950000, 1, '{"processor":"Intel Core i5 (13th Gen)","ram":"16GB DDR4","storage":"256GB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 24 CR-0321NH All-in-One (Shell White)', 'hp-24-cr-0321nh-be9b4ea',
  'Intel Core i7 up to 5.0GHz. 13th Gen. 1TB SSD. 16GB DDR4. Intel Iris Xe graphics. 23.8" FHD touchscreen. HP white wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Shell White.',
  1326000, 1, '{"processor":"Intel Core i7 (13th Gen)","ram":"16GB DDR4","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 27 CR-0088NH All-in-One (Jet Black)', 'hp-27-cr-0088nh-91a37ea',
  'Intel Core i7 up to 5.0GHz. 13th Gen. 1TB SSD. 16GB DDR4. Intel Iris Xe graphics. 27" FHD touchscreen. HP black wired keyboard and mouse. Webcam, Bluetooth, Wi‑Fi. FreeDOS. Color: Jet Black.',
  1418000, 1, '{"processor":"Intel Core i7 (13th Gen)","ram":"16GB DDR4","storage":"1TB SSD"}'::jsonb
FROM categories WHERE slug = 'all-in-ones' LIMIT 1;

-- ========== MONITORS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell 27 Monitor S2725H (White)', 'dell-27-monitor-s2725h-j2f3hp3',
  'Dell S2725H 27" Full HD 100Hz 4ms IPS. Built-in 2x5W speakers. Tilt. 2x HDMI (HDCP1.4). Color: White.',
  300000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Series 3 Pro 322PV 22" Monitor', 'hp-series-3-pro-322pv-9u5a2aa',
  'HP Series 3 Pro 21.45" FHD 22" (1920x1080 @ 100Hz). VA LCD. 1 HDMI 1.4, 1 VGA.',
  142000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP P24v G5 Monitor (64W18AA)', 'hp-p24v-g5-64w18aa',
  'HP P24v G5 FHD. 23.8" (60.5cm). VA LCD panel.',
  170000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Series 5 524SW Monitor (White)', 'hp-series-5-524sw-94c21aa',
  'HP Series 5 524SW White. 23.8" FHD IPS. 100Hz. HDMI & VGA. Anti-glare, flicker-free. Works With Chromebook. 5ms. 1920x1080.',
  220000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Series 5 524SA Monitor', 'hp-series-5-524sa-94c36aa',
  'HP Series 5 524SA. 23.8" FHD IPS. 100Hz. HDMI & VGA. Anti-glare, flicker-free. Works With Chromebook. Audio jack (Audio in).',
  230000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 527sf Series 5 27" Monitor (Black)', 'hp-series-5-527sf-94f44aa',
  'HP 527sf Series 5. 27" black. 1920x1080 FHD. IPS, flat. 100Hz, 5ms, 300 nits, 99% sRGB, 1500:1 contrast. VGA, 2x HDMI 1.4. Anti-glare, edge-lit. Silver.',
  230000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP 527sw Series 5 27" Monitor (White)', 'hp-series-5-527sw-94f46as',
  'HP 527sw Series 5. 27" white. 1920x1080 FHD. IPS, flat. 100Hz, 5ms, 300 nits, 99% sRGB, 1500:1 contrast. VGA, 2x HDMI 1.4. Anti-glare, edge-lit. Silver.',
  240000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Series 5 527SA 27" Monitor', 'hp-series-5-527sa',
  'HP Series 5 527SA. 27" FHD. IPS, 99% sRGB, 1500:1 contrast, 300 nits. Eye Ease, Eye-safe. Audio speakers (2024).',
  260000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP Series 5 532SF 32" Monitor', 'hp-series-5-532sf',
  'HP Series 5 32SF. 32" FHD. VA LCD. 99% sRGB, 3000:1 contrast, 300 nits. Eye Ease, Eye-safe. 2 HDMI, 1 VGA (2024).',
  350000, 1, '{}'::jsonb
FROM categories WHERE slug = 'monitors' LIMIT 1;

-- ========== PRINTERS ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'HP DeskJet Ink Advantage 2875 All-in-One Printer [60K47C]', 'hp-deskjet-ink-advantage-2875-60k47c',
  'HP DeskJet Ink Advantage 2875 All-in-One. Replacement for HP DeskJet 2720.',
  89000, 1, '{}'::jsonb
FROM categories WHERE slug = 'printers' LIMIT 1;

-- ========== ACCESSORIES (Laptop Accessories) ==========
INSERT INTO products (category_id, name, slug, description, price, stock, specs)
SELECT id, 'Dell Essential Backpack 15 (15.6 to 17 inches)', 'dell-essential-backpack-15',
  'Dell Essential Backpack. Fits 15.6" to 17" laptops.',
  18000, 1, '{}'::jsonb
FROM categories WHERE slug = 'laptop-accessories' LIMIT 1;
