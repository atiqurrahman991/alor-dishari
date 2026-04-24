-- =============================================================
--  Alor Dishari — Phase 2: Transparency & Role-Based Schema
--  Run this script in the Supabase SQL Editor
-- =============================================================

-- 1. Add roles and auth mapping to Members table
ALTER TABLE public.members 
ADD COLUMN IF NOT EXISTS auth_id UUID REFERENCES auth.users(id) ON DELETE SET NULL UNIQUE,
ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member'));

-- 2. Add Status to Savings
ALTER TABLE public.savings
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected'));

-- 3. Add Status to Installments
ALTER TABLE public.installments
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected'));

-- 4. Update Trigger Logic: Only Update Balances when 'APPROVED'
-- Drop the old trigger to recreate it with new logic
DROP TRIGGER IF EXISTS trg_reduce_outstanding ON public.installments;

CREATE OR REPLACE FUNCTION public.fn_process_installment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- If a pending installment gets approved
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
        UPDATE public.loans
        SET
            outstanding_amount = GREATEST(outstanding_amount - NEW.paid_amount, 0),
            status = CASE
                        WHEN (outstanding_amount - NEW.paid_amount) <= 0 THEN 'closed'
                        ELSE status
                     END
        WHERE id = NEW.loan_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_process_installment
    AFTER UPDATE ON public.installments
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_process_installment();

-- =============================================================
-- End of Script
-- =============================================================
