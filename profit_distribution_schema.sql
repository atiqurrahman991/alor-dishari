-- =============================================================
-- Alor Dishari — Profit Distribution Tables
-- Run this script in the Supabase SQL Editor
-- =============================================================

-- 1. Table to record each distribution event
CREATE TABLE IF NOT EXISTS public.profit_distributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_name TEXT NOT NULL, -- e.g., "April 2024" or "Q1 2024"
    total_profit_amount NUMERIC(15, 2) NOT NULL,
    total_eligible_savings NUMERIC(15, 2) NOT NULL, -- Total savings in system at time of distribution
    distributed_at TIMESTAMPTZ DEFAULT now(),
    notes TEXT,
    created_by UUID REFERENCES auth.users(id)
);

-- 2. Table to record each member's share in a distribution
CREATE TABLE IF NOT EXISTS public.member_profit_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    distribution_id UUID NOT NULL REFERENCES public.profit_distributions(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
    share_amount NUMERIC(15, 2) NOT NULL,
    member_savings_at_time NUMERIC(15, 2) NOT NULL, -- Their balance when this was calculated
    status TEXT DEFAULT 'distributed',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_profit_dist_period ON public.profit_distributions(period_name);
CREATE INDEX IF NOT EXISTS idx_member_profit_share_member ON public.member_profit_shares(member_id);
CREATE INDEX IF NOT EXISTS idx_member_profit_share_dist ON public.member_profit_shares(distribution_id);
