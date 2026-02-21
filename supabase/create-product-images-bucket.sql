-- Create the product-images storage bucket (required for admin image uploads).
-- Run this in Supabase SQL Editor if you get "bucket not found" when uploading product images.
--
-- If this fails (e.g. permission or schema), create the bucket manually:
-- Dashboard → Storage → New bucket → Name: product-images → Public: ON → Create.

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;
