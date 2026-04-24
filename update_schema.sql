-- =============================================================
-- Update Script for Savings & Installments
-- Run this block in the Supabase SQL Editor
-- =============================================================

-- Add new columns to Savings table
ALTER TABLE public.savings 
  ADD COLUMN IF NOT EXISTS month TEXT,
  ADD COLUMN IF NOT EXISTS payment_method TEXT,
  ADD COLUMN IF NOT EXISTS trx_id TEXT,
  ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add new columns to Installments table
ALTER TABLE public.installments 
  ADD COLUMN IF NOT EXISTS month TEXT,
  ADD COLUMN IF NOT EXISTS payment_method TEXT,
  ADD COLUMN IF NOT EXISTS trx_id TEXT,
  ADD COLUMN IF NOT EXISTS notes TEXT;
