-- =====================================================
-- MifugoCare Database Setup SQL
-- =====================================================
-- Run this entire script in Supabase SQL Editor
-- Dashboard: https://supabase.com/dashboard/project/slkihxgkafkzasnpjmbl/sql/new
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('farmer', 'veterinarian', 'administrator')),
  phone_number TEXT,
  profile_image_url TEXT,
  license_number TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login TIMESTAMPTZ,
  auth_token TEXT,
  token_expiry TIMESTAMPTZ,
  is_verified BOOLEAN DEFAULT FALSE,
  two_factor_enabled BOOLEAN DEFAULT FALSE
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Anyone can create profile on signup" ON users;

-- Users can read their own data
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own data
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = user_id);

-- Anyone can insert (for sign up)
CREATE POLICY "Anyone can create profile on signup"
  ON users FOR INSERT
  WITH CHECK (true);

-- =====================================================
-- LIVESTOCK TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS livestock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  breed TEXT,
  tag_number TEXT,
  date_of_birth TIMESTAMPTZ,
  gender TEXT,
  weight REAL,
  color TEXT,
  image_url TEXT,
  registered_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes TEXT,
  diagnosis_history TEXT[], -- Array of diagnosis IDs
  is_synced BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE livestock ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own livestock" ON livestock;
DROP POLICY IF EXISTS "Users can insert own livestock" ON livestock;
DROP POLICY IF EXISTS "Users can update own livestock" ON livestock;
DROP POLICY IF EXISTS "Users can delete own livestock" ON livestock;

-- Users can only see their own livestock
CREATE POLICY "Users can view own livestock"
  ON livestock FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own livestock"
  ON livestock FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own livestock"
  ON livestock FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own livestock"
  ON livestock FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- DIAGNOSES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS diagnoses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  livestock_id UUID REFERENCES livestock(id) ON DELETE SET NULL,
  disease_name TEXT NOT NULL,
  confidence REAL NOT NULL,
  image_path TEXT NOT NULL,
  diagnosis_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  symptoms TEXT[],
  recommended_treatments TEXT[],
  prevention_steps TEXT[],
  severity_level INTEGER NOT NULL,
  notes TEXT,
  is_synced BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE diagnoses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own diagnoses" ON diagnoses;
DROP POLICY IF EXISTS "Users can insert own diagnoses" ON diagnoses;
DROP POLICY IF EXISTS "Users can update own diagnoses" ON diagnoses;
DROP POLICY IF EXISTS "Users can delete own diagnoses" ON diagnoses;

-- Users can only see their own diagnoses
CREATE POLICY "Users can view own diagnoses"
  ON diagnoses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own diagnoses"
  ON diagnoses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own diagnoses"
  ON diagnoses FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own diagnoses"
  ON diagnoses FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- DISEASES TABLE (Reference Data)
-- =====================================================
CREATE TABLE IF NOT EXISTS diseases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  symptoms TEXT[],
  causes TEXT[],
  treatments TEXT[],
  prevention_methods TEXT[],
  severity_level INTEGER NOT NULL,
  image_url TEXT,
  is_contagious BOOLEAN DEFAULT FALSE,
  affected_species TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security but allow read for all authenticated users
ALTER TABLE diseases ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Anyone can view diseases" ON diseases;

CREATE POLICY "Anyone can view diseases"
  ON diseases FOR SELECT
  TO authenticated
  USING (true);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_livestock_user_id ON livestock(user_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_user_id ON diagnoses(user_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_livestock_id ON diagnoses(livestock_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_date ON diagnoses(diagnosis_date DESC);

-- =====================================================
-- TRIGGERS
-- =====================================================
-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_livestock_updated_at ON livestock;

-- Create trigger for livestock
CREATE TRIGGER update_livestock_updated_at 
  BEFORE UPDATE ON livestock
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SEED DATA: Common Livestock Diseases
-- =====================================================
INSERT INTO diseases (name, description, symptoms, causes, treatments, prevention_methods, severity_level, is_contagious, affected_species)
VALUES 
  (
    'East Coast Fever (ECF)',
    'A tick-borne disease caused by the parasite Theileria parva, common in East Africa. Fatal if not treated early.',
    ARRAY['High fever (40-41°C)', 'Swollen lymph nodes', 'Nasal discharge', 'Difficulty breathing', 'Loss of appetite', 'Weakness'],
    ARRAY['Transmitted by brown ear ticks', 'Common in endemic areas', 'Poor tick control', 'Movement of infected animals'],
    ARRAY['Early antibiotic treatment (Oxytetracycline)', 'Tick control measures', 'Supportive therapy with fluids', 'Consult veterinarian immediately'],
    ARRAY['Regular tick control (dipping/spraying)', 'Vaccination in endemic areas', 'Pasture management', 'Quarantine new animals', 'Weekly inspection'],
    85,
    true,
    ARRAY['Cattle']
  ),
  (
    'Lumpy Skin Disease',
    'A viral disease affecting cattle, characterized by skin nodules. Spreads through insect vectors.',
    ARRAY['Skin nodules (lumps)', 'High fever', 'Reduced milk production', 'Weight loss', 'Swollen lymph nodes', 'Lesions on skin'],
    ARRAY['Spread by flies and mosquitoes', 'Contact with infected animals', 'Contaminated equipment', 'Poor biosecurity'],
    ARRAY['Vaccination (preventive)', 'Antibiotics for secondary infections', 'Anti-inflammatory drugs', 'Supportive care and nutrition', 'Isolation'],
    ARRAY['Annual vaccination', 'Vector control (flies, mosquitoes)', 'Isolate infected animals', 'Biosecurity measures', 'Quarantine protocols'],
    75,
    true,
    ARRAY['Cattle']
  ),
  (
    'Foot and Mouth Disease (FMD)',
    'Highly contagious viral disease affecting cloven-hoofed animals. Causes economic losses.',
    ARRAY['Blisters on mouth, feet, teats', 'Excessive drooling', 'Lameness', 'Fever', 'Reluctance to move or eat', 'Weight loss'],
    ARRAY['Highly contagious virus', 'Direct contact with infected animals', 'Contaminated feed/water', 'Airborne transmission'],
    ARRAY['No specific cure - supportive care', 'Isolate affected animals', 'Soft feed and clean water', 'Anti-inflammatory drugs', 'Consult veterinarian'],
    ARRAY['Regular vaccination', 'Movement restrictions', 'Quarantine new animals', 'Biosecurity protocols', 'Disinfection'],
    90,
    true,
    ARRAY['Cattle', 'Sheep', 'Goats', 'Pigs']
  ),
  (
    'Mastitis',
    'Inflammation of the udder, usually caused by bacterial infection. Common in dairy cattle.',
    ARRAY['Swollen, hard udder', 'Abnormal milk (clots, blood)', 'Fever', 'Reduced milk production', 'Pain when milking', 'Hot udder'],
    ARRAY['Bacterial infection', 'Poor milking hygiene', 'Teat injuries', 'Contaminated equipment', 'Stress'],
    ARRAY['Antibiotics (intramammary or systemic)', 'Anti-inflammatory drugs', 'Frequent milking', 'Proper hygiene during milking', 'Rest'],
    ARRAY['Clean milking equipment', 'Teat dipping after milking', 'Dry cow therapy', 'Good housing conditions', 'Regular screening'],
    60,
    false,
    ARRAY['Cattle', 'Goats', 'Sheep']
  ),
  (
    'Mange (Scabies)',
    'Parasitic skin disease caused by mites. Causes intense itching and skin damage.',
    ARRAY['Intense itching', 'Hair loss (alopecia)', 'Thickened, wrinkled skin', 'Scabs and crusty lesions', 'Weight loss', 'Restlessness'],
    ARRAY['Mite infestation', 'Direct contact with infected animals', 'Contaminated equipment', 'Overcrowding', 'Poor nutrition'],
    ARRAY['Acaricide sprays or dips', 'Ivermectin injections', 'Isolate infected animals', 'Repeat treatment after 10-14 days', 'Clean housing'],
    ARRAY['Regular inspection of animals', 'Quarantine new animals', 'Clean and disinfect equipment', 'Avoid overcrowding', 'Good nutrition'],
    55,
    true,
    ARRAY['Cattle', 'Sheep', 'Goats', 'Pigs']
  ),
  (
    'Tick Infestation',
    'Heavy burden of external parasites that feed on blood. Can transmit diseases.',
    ARRAY['Visible ticks on skin', 'Anemia (pale gums)', 'Weight loss', 'Restlessness', 'Reduced productivity', 'Skin irritation'],
    ARRAY['Poor tick control', 'Inadequate dipping/spraying', 'Movement from endemic areas', 'Pasture with high tick burden'],
    ARRAY['Acaricide dips or sprays', 'Manual tick removal', 'Ivermectin treatment', 'Treat underlying diseases', 'Nutrition support'],
    ARRAY['Weekly dipping or spraying', 'Pasture rotation', 'Keep grass short', 'Inspect animals daily', 'Use appropriate acaricides'],
    50,
    false,
    ARRAY['Cattle', 'Sheep', 'Goats']
  ),
  (
    'Ringworm',
    'Fungal infection of the skin causing circular patches of hair loss.',
    ARRAY['Circular patches of hair loss', 'Scaly, crusty skin', 'Grey-white lesions', 'Usually on head, neck, back', 'Minimal itching'],
    ARRAY['Fungal infection', 'Direct contact with infected animals', 'Contaminated equipment', 'Damp conditions', 'Poor immunity'],
    ARRAY['Topical antifungal creams', 'Oral antifungals (severe cases)', 'Isolate infected animals', 'Disinfect equipment and housing', 'Sunlight exposure'],
    ARRAY['Good hygiene practices', 'Avoid contact with infected animals', 'Disinfect equipment regularly', 'Improve nutrition and immunity', 'Dry housing'],
    40,
    true,
    ARRAY['Cattle', 'Sheep', 'Goats', 'Horses']
  ),
  (
    'CBPP (Contagious Bovine Pleuropneumonia)',
    'Highly contagious bacterial disease affecting the lungs and pleura of cattle.',
    ARRAY['Persistent coughing', 'Labored breathing', 'High fever', 'Nasal discharge', 'Weight loss and weakness', 'Chest pain'],
    ARRAY['Bacterial infection (Mycoplasma)', 'Airborne transmission', 'Direct contact', 'Contaminated water', 'Poor ventilation'],
    ARRAY['Antibiotics (early stage)', 'Supportive therapy', 'Isolation from herd', 'Slaughter in severe cases', 'Veterinary supervision'],
    ARRAY['Vaccination', 'Movement control', 'Quarantine infected herds', 'Report to veterinary authorities', 'Good ventilation'],
    95,
    true,
    ARRAY['Cattle']
  ),
  (
    'Healthy - No Disease Detected',
    'Animal shows no signs of disease. Continue regular monitoring and preventive care.',
    ARRAY['Normal appetite', 'Active and alert', 'Normal body temperature', 'No visible lesions', 'Good body condition', 'Bright eyes'],
    ARRAY['Good health management', 'Proper nutrition', 'Regular vaccinations', 'Clean environment'],
    ARRAY['Continue regular monitoring', 'Maintain vaccination schedule', 'Provide balanced nutrition', 'Ensure clean water supply'],
    ARRAY['Regular health checks', 'Timely vaccinations', 'Good hygiene practices', 'Balanced diet and minerals', 'Stress management'],
    0,
    false,
    ARRAY['Cattle', 'Sheep', 'Goats', 'Pigs']
  )
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- VERIFICATION
-- =====================================================
-- Check that all tables were created
SELECT 
  'users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'livestock', COUNT(*) FROM livestock
UNION ALL
SELECT 'diagnoses', COUNT(*) FROM diagnoses
UNION ALL
SELECT 'diseases', COUNT(*) FROM diseases;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
SELECT 'Database setup complete! ✅ All tables, policies, and seed data created successfully.' as status;

