-- =============================================================
-- Alor Dishari — Reset Everything and Restart Fresh!
-- ⚠️ WARNING: This will delete ALL data (Members, Savings, Loans)
-- =============================================================

-- 1. Wipe all data cleanly (CASCADE deletes savings, loans, installments too)
TRUNCATE TABLE public.members CASCADE;

-- 2. Insert the 4 Demo Members (so you have data to test)
-- Notice we leave auth_id as NULL because they are just dummy members
INSERT INTO public.members (name, mobile, nid, category, address, role)
VALUES 
  ('Abdur Rahman', '01711000001', '1990456123789', 'SME', 'Dhaka, Mirpur', 'member'),
  ('Jannatul Ferdous', '01822000002', '1985456123780', 'General', 'Comilla, Sadar', 'member'),
  ('Karim Hasan', '01933000003', '1992456123781', 'Agriculture', 'Sylhet, Zindabazar', 'member'),
  ('Ayesha Siddiqa', '01544000004', '1988456123782', 'SME', 'Rajshahi, Boalia', 'member');

-- 3. To make sure you have the required columns (just to be safe)
ALTER TABLE public.members 
  ADD COLUMN IF NOT EXISTS auth_id UUID,
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'member';
