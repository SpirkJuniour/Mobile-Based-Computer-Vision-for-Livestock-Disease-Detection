-- ============================================================================
-- MIFUGO CARE - COMPLETE SUPABASE DATABASE SETUP
-- ============================================================================
-- This is a consolidated SQL script that includes all database schema,
-- triggers, policies, and storage configurations needed for Mifugo Care.
-- Run this entire script in Supabase Dashboard → SQL Editor for a complete setup.
-- ============================================================================

-- ============================================================================
-- SECTION 1: CREATE TABLES
-- ============================================================================

-- Drop existing tables if they exist (in reverse order of dependencies)
-- WARNING: This will delete all data! Only use on fresh setups or when resetting.
-- DROP TABLE IF EXISTS notifications CASCADE;
-- DROP TABLE IF EXISTS vet_cases CASCADE;
-- DROP TABLE IF EXISTS diagnoses CASCADE;
-- DROP TABLE IF EXISTS livestock CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- ----------------------------------------------------------------------------
-- 1. USERS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('farmer', 'veterinarian')),
  phone_number TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ----------------------------------------------------------------------------
-- 2. LIVESTOCK TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS livestock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  breed TEXT,
  age INTEGER,
  gender TEXT,
  health_status TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_livestock_farmer_id ON livestock(farmer_id);
CREATE INDEX IF NOT EXISTS idx_livestock_type ON livestock(type);

-- ----------------------------------------------------------------------------
-- 3. DIAGNOSES TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS diagnoses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  livestock_id UUID NOT NULL REFERENCES livestock(id) ON DELETE CASCADE,
  farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  disease_label TEXT NOT NULL,
  confidence_score DOUBLE PRECISION NOT NULL,
  recommended_action TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  vet_id UUID REFERENCES users(id),
  vet_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure vet_id column exists (handles existing tables)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'diagnoses' 
    AND column_name = 'vet_id'
  ) THEN
    ALTER TABLE diagnoses ADD COLUMN vet_id UUID REFERENCES users(id);
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_diagnoses_livestock_id ON diagnoses(livestock_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_farmer_id ON diagnoses(farmer_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_vet_id ON diagnoses(vet_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_status ON diagnoses(status);
CREATE INDEX IF NOT EXISTS idx_diagnoses_created_at ON diagnoses(created_at DESC);

-- ----------------------------------------------------------------------------
-- 4. VET CASES TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS vet_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  diagnosis_id UUID NOT NULL REFERENCES diagnoses(id) ON DELETE CASCADE,
  vet_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved', 'closed')),
  notes TEXT,
  treatment_plan TEXT,
  follow_up_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_vet_cases_diagnosis_id ON vet_cases(diagnosis_id);
CREATE INDEX IF NOT EXISTS idx_vet_cases_vet_id ON vet_cases(vet_id);
CREATE INDEX IF NOT EXISTS idx_vet_cases_farmer_id ON vet_cases(farmer_id);
CREATE INDEX IF NOT EXISTS idx_vet_cases_status ON vet_cases(status);

-- ----------------------------------------------------------------------------
-- 5. NOTIFICATIONS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================================================
-- SECTION 2: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE livestock ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnoses ENABLE ROW LEVEL SECURITY;
ALTER TABLE vet_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SECTION 3: ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- USERS TABLE POLICIES
-- ----------------------------------------------------------------------------

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can read other users for matching" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Enable insert for authenticated users during signup" ON users;

-- Policy: Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT 
  USING (auth.uid() = id);

-- Policy: Users can read other users (for vet-farmer interactions)
CREATE POLICY "Users can read other users for matching" ON users
  FOR SELECT 
  USING (true);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE 
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy: Allow authenticated users to insert (for signup)
-- The trigger handles this, but this serves as a backup
CREATE POLICY "Enable insert for authenticated users during signup" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() IS NOT NULL);

-- ----------------------------------------------------------------------------
-- LIVESTOCK TABLE POLICIES
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Farmers can manage own livestock" ON livestock;

CREATE POLICY "Farmers can manage own livestock" ON livestock
  FOR ALL USING (auth.uid() = farmer_id);

-- ----------------------------------------------------------------------------
-- DIAGNOSES TABLE POLICIES
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Farmers can manage own diagnoses" ON diagnoses;
DROP POLICY IF EXISTS "Vets can read all diagnoses" ON diagnoses;
DROP POLICY IF EXISTS "Vets can update diagnoses" ON diagnoses;

-- Policy: Farmers can manage their own diagnoses
CREATE POLICY "Farmers can manage own diagnoses" ON diagnoses
  FOR ALL USING (auth.uid() = farmer_id);

-- Policy: Vets can read all diagnoses
CREATE POLICY "Vets can read all diagnoses" ON diagnoses
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'veterinarian')
  );

-- Policy: Vets can update diagnoses
CREATE POLICY "Vets can update diagnoses" ON diagnoses
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'veterinarian')
  );

-- ----------------------------------------------------------------------------
-- VET CASES TABLE POLICIES
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Vets can manage own cases" ON vet_cases;
DROP POLICY IF EXISTS "Farmers can read own cases" ON vet_cases;

-- Policy: Vets can manage their own cases
CREATE POLICY "Vets can manage own cases" ON vet_cases
  FOR ALL USING (auth.uid() = vet_id);

-- Policy: Farmers can read their own cases
CREATE POLICY "Farmers can read own cases" ON vet_cases
  FOR SELECT USING (auth.uid() = farmer_id);

-- ----------------------------------------------------------------------------
-- NOTIFICATIONS TABLE POLICIES
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can read own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;

-- Policy: Users can read their own notifications
CREATE POLICY "Users can read own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can update their own notifications
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================================
-- SECTION 4: DATABASE TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- AUTO-CREATE USER PROFILE TRIGGER
-- ----------------------------------------------------------------------------
-- This trigger automatically creates a user profile in the public.users table
-- when a new user signs up through Supabase Auth.
-- This is the most reliable method as it bypasses RLS policies.

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, role, phone_number, created_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'farmer'),
    NEW.raw_user_meta_data->>'phone_number',
    NOW()
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    display_name = COALESCE(EXCLUDED.display_name, users.display_name),
    role = COALESCE(EXCLUDED.role, users.role),
    phone_number = COALESCE(EXCLUDED.phone_number, users.phone_number),
    updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger that fires when a new user is created in auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- AUTO-UPDATE TIMESTAMP TRIGGER
-- ----------------------------------------------------------------------------
-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at on relevant tables
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_livestock_updated_at ON livestock;
CREATE TRIGGER update_livestock_updated_at
  BEFORE UPDATE ON livestock
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_diagnoses_updated_at ON diagnoses;
CREATE TRIGGER update_diagnoses_updated_at
  BEFORE UPDATE ON diagnoses
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_vet_cases_updated_at ON vet_cases;
CREATE TRIGGER update_vet_cases_updated_at
  BEFORE UPDATE ON vet_cases
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- SECTION 5: STORAGE POLICIES
-- ============================================================================
-- NOTE: Storage buckets must be created manually in Supabase Dashboard
-- Go to Storage → Create Bucket and create:
-- 1. 'livestock_images' - public read, authenticated write
-- 2. 'diagnosis_images' - public read, authenticated write

-- ----------------------------------------------------------------------------
-- POLICIES FOR livestock_images BUCKET
-- ----------------------------------------------------------------------------

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can upload livestock" ON storage.objects;
DROP POLICY IF EXISTS "Public can read livestock images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own livestock images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own livestock images" ON storage.objects;

-- Allow authenticated users to upload to livestock_images
CREATE POLICY "Authenticated users can upload livestock" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'livestock_images' AND
    auth.role() = 'authenticated'
  );

-- Allow public read access to livestock_images
CREATE POLICY "Public can read livestock images" ON storage.objects
  FOR SELECT USING (bucket_id = 'livestock_images');

-- Allow authenticated users to update their own uploads
CREATE POLICY "Users can update own livestock images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'livestock_images' AND
    auth.role() = 'authenticated'
  );

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Users can delete own livestock images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'livestock_images' AND
    auth.role() = 'authenticated'
  );

-- ----------------------------------------------------------------------------
-- POLICIES FOR diagnosis_images BUCKET
-- ----------------------------------------------------------------------------

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can upload diagnosis" ON storage.objects;
DROP POLICY IF EXISTS "Public can read diagnosis images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own diagnosis images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own diagnosis images" ON storage.objects;

-- Allow authenticated users to upload to diagnosis_images
CREATE POLICY "Authenticated users can upload diagnosis" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'diagnosis_images' AND
    auth.role() = 'authenticated'
  );

-- Allow public read access to diagnosis_images
CREATE POLICY "Public can read diagnosis images" ON storage.objects
  FOR SELECT USING (bucket_id = 'diagnosis_images');

-- Allow authenticated users to update their own uploads
CREATE POLICY "Users can update own diagnosis images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'diagnosis_images' AND
    auth.role() = 'authenticated'
  );

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Users can delete own diagnosis images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'diagnosis_images' AND
    auth.role() = 'authenticated'
  );

-- ============================================================================
-- SECTION 6: VERIFICATION QUERIES
-- ============================================================================
-- Run these queries after executing the script to verify everything is set up correctly

-- Check that trigger was created
-- SELECT 
--   trigger_name, 
--   event_manipulation, 
--   event_object_table,
--   action_statement
-- FROM information_schema.triggers 
-- WHERE trigger_name = 'on_auth_user_created';

-- Check that all policies exist
-- SELECT 
--   schemaname, 
--   tablename, 
--   policyname, 
--   permissive, 
--   roles, 
--   cmd
-- FROM pg_policies 
-- WHERE schemaname = 'public'
-- ORDER BY tablename, policyname;

-- Check that all tables exist
-- SELECT 
--   table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
--   AND table_name IN ('users', 'livestock', 'diagnoses', 'vet_cases', 'notifications')
-- ORDER BY table_name;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
-- Next steps:
-- 1. Create storage buckets in Supabase Dashboard:
--    - Storage → Create Bucket → 'livestock_images' (public)
--    - Storage → Create Bucket → 'diagnosis_images' (public)
-- 2. Configure your Flutter app with Supabase credentials
-- 3. Test user signup to verify the trigger works
-- 4. Test image upload to verify storage policies work
-- ============================================================================

