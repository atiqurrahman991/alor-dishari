-- Table for notices/announcements
CREATE TABLE IF NOT EXISTS notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority TEXT DEFAULT 'normal', -- 'normal' or 'high'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
CREATE POLICY "Admin full access to notices" 
ON notices FOR ALL 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM members WHERE id = auth.uid() AND role = 'admin')
)
WITH CHECK (
    EXISTS (SELECT 1 FROM members WHERE id = auth.uid() AND role = 'admin')
);

-- Members can only view
CREATE POLICY "Members can view notices" 
ON notices FOR SELECT 
TO authenticated 
USING (true);
