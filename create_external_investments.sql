-- Table for external investments made by the samity
CREATE TABLE IF NOT EXISTS external_investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    investment_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
    status TEXT DEFAULT 'active', -- 'active' or 'closed'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE external_investments ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
CREATE POLICY "Admin full access to external investments" 
ON external_investments FOR ALL 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM members WHERE id = auth.uid() AND role = 'admin')
)
WITH CHECK (
    EXISTS (SELECT 1 FROM members WHERE id = auth.uid() AND role = 'admin')
);

-- Members can only view
CREATE POLICY "Members can view external investments" 
ON external_investments FOR SELECT 
TO authenticated 
USING (true);
