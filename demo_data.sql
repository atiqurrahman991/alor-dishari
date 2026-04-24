-- =============================================================
-- Alor Dishari — Demo Data Insertion Script
-- Run this in the Supabase SQL Editor to get dummy members!
-- =============================================================

INSERT INTO public.members (name, mobile, nid, category, address, role)
VALUES 
  ('Abdur Rahman', '01711000001', '1990456123789', 'SME', 'Dhaka, Mirpur', 'member'),
  ('Jannatul Ferdous', '01822000002', '1985456123780', 'General', 'Comilla, Sadar', 'member'),
  ('Karim Hasan', '01933000003', '1992456123781', 'Agriculture', 'Sylhet, Zindabazar', 'member'),
  ('Ayesha Siddiqa', '01544000004', '1988456123782', 'SME', 'Rajshahi, Boalia', 'member')
ON CONFLICT (nid) DO NOTHING;

-- If you also want to add some demo savings directly, you can run the below as well (Optional)
-- INSERT INTO public.savings (member_id, deposit_amount, status)
-- SELECT id, 1000.00, 'approved' FROM public.members WHERE name = 'Abdur Rahman';
