-- =============================================================
-- Alor Dishari — Row Level Security (RLS) Policies
-- Run this script in the Supabase SQL Editor
-- =============================================================

-- 1. Enable RLS on all tables
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profit_distributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_profit_shares ENABLE ROW LEVEL SECURITY;

-- 2. HELPER FUNCTION: Check if user is Admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.members 
    WHERE auth_id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================
-- POLICIES FOR 'members' TABLE
-- =============================================================
CREATE POLICY "Admins have full access to members" 
ON public.members FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Members can view their own profile" 
ON public.members FOR SELECT TO authenticated USING (auth_id = auth.uid());

CREATE POLICY "Allow signup: anyone can insert during registration" 
ON public.members FOR INSERT TO authenticated WITH CHECK (auth_id = auth.uid());

-- =============================================================
-- POLICIES FOR 'savings' TABLE
-- =============================================================
CREATE POLICY "Admins have full access to savings" 
ON public.savings FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Members can view their own savings" 
ON public.savings FOR SELECT TO authenticated USING (member_id IN (SELECT id FROM public.members WHERE auth_id = auth.uid()));

CREATE POLICY "Members can request savings/withdrawal" 
ON public.savings FOR INSERT TO authenticated WITH CHECK (member_id IN (SELECT id FROM public.members WHERE auth_id = auth.uid()));

-- =============================================================
-- POLICIES FOR 'loans' TABLE
-- =============================================================
CREATE POLICY "Admins have full access to loans" 
ON public.loans FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Members can view their own loans" 
ON public.loans FOR SELECT TO authenticated USING (member_id IN (SELECT id FROM public.members WHERE auth_id = auth.uid()));

-- =============================================================
-- POLICIES FOR 'installments' TABLE
-- =============================================================
CREATE POLICY "Admins have full access to installments" 
ON public.installments FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Members can view their own installments" 
ON public.installments FOR SELECT TO authenticated USING (
    loan_id IN (SELECT id FROM public.loans WHERE member_id IN (SELECT id FROM public.members WHERE auth_id = auth.uid()))
);

CREATE POLICY "Members can submit installments" 
ON public.installments FOR INSERT TO authenticated WITH CHECK (
    loan_id IN (SELECT id FROM public.loans WHERE member_id IN (SELECT id FROM public.members WHERE auth_id = auth.uid()))
);

-- =============================================================
-- POLICIES FOR 'profit_distributions' TABLE
-- =============================================================
CREATE POLICY "Admins have full access to distributions" 
ON public.profit_distributions FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Everyone can view distribution metadata" 
ON public.profit_distributions FOR SELECT TO authenticated USING (true);

-- =============================================================
-- POLICIES FOR 'member_profit_shares' TABLE
-- =============================================================
CREATE POLICY "Admins have full access to profit shares" 
ON public.member_profit_shares FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Members can view their own profit shares" 
ON public.member_profit_shares FOR SELECT TO authenticated USING (member_id IN (SELECT id FROM public.members WHERE auth_id = auth.uid()));
