-- Language King: optional fields for picture-word learning
-- Run this in Supabase SQL editor before syncing image metadata.

alter table public.vocab_items
  add column if not exists image text,
  add column if not exists example text,
  add column if not exists example_translation text,
  add column if not exists difficulty int,
  add column if not exists word_type text;
