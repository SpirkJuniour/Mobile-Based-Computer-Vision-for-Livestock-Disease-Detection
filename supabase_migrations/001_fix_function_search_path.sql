-- =====================================================================
-- SQL Migration: Fix Function Search Path Security Issue
-- =====================================================================
-- Purpose: Fix the mutable search_path security vulnerability in the
--          update_updated_at_column() function
-- Date: 2025-10-27
-- Issue: Supabase lint detected function with mutable search_path
-- Severity: HIGH - Can lead to privilege escalation and schema-shadowing
-- =====================================================================

-- Step 1: Drop and recreate the vulnerable function with fixed search_path
-- =====================================================================

DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public  -- ← CRITICAL: Fixed search_path
SECURITY DEFINER  -- Function runs with creator's privileges
AS $$
BEGIN
  -- Update the updated_at column to current timestamp
  -- Using pg_catalog.now() for explicit schema qualification
  NEW.updated_at := pg_catalog.now();
  RETURN NEW;
END;
$$;

-- Add function comment for documentation
COMMENT ON FUNCTION public.update_updated_at_column() IS 
'Trigger function to automatically update updated_at column on row updates. 
Search path is fixed to pg_catalog,public to prevent schema-shadowing attacks.';


-- Step 2: Verify and recreate triggers using this function
-- =====================================================================

-- Check if triggers exist and recreate them for common tables
-- Users table trigger
DROP TRIGGER IF EXISTS set_updated_at_users ON public.users;
CREATE TRIGGER set_updated_at_users
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Livestock table trigger
DROP TRIGGER IF EXISTS set_updated_at_livestock ON public.livestock;
CREATE TRIGGER set_updated_at_livestock
  BEFORE UPDATE ON public.livestock
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Diagnoses table trigger
DROP TRIGGER IF EXISTS set_updated_at_diagnoses ON public.diagnoses;
CREATE TRIGGER set_updated_at_diagnoses
  BEFORE UPDATE ON public.diagnoses
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Diseases table trigger (if exists)
DROP TRIGGER IF EXISTS set_updated_at_diseases ON public.diseases;
CREATE TRIGGER set_updated_at_diseases
  BEFORE UPDATE ON public.diseases
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();


-- Step 3: Security audit query to check for other vulnerable functions
-- =====================================================================

-- Run this query to find other functions with mutable search_path
-- Copy and paste into Supabase SQL Editor to audit your database

/*
SELECT 
  n.nspname AS schema_name,
  p.proname AS function_name,
  pg_get_function_identity_arguments(p.oid) AS arguments,
  CASE 
    WHEN p.prosecdef THEN 'SECURITY DEFINER ⚠️'
    ELSE 'SECURITY INVOKER'
  END AS security_mode,
  CASE 
    WHEN p.proconfig IS NULL THEN '❌ VULNERABLE (no fixed search_path)'
    ELSE '✓ SAFE (search_path: ' || array_to_string(p.proconfig, ', ') || ')'
  END AS search_path_status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.prokind = 'f'  -- Only functions, not procedures
ORDER BY 
  CASE WHEN p.proconfig IS NULL THEN 0 ELSE 1 END,  -- Vulnerable first
  p.proname;
*/


-- Step 4: Apply to all other custom functions (template)
-- =====================================================================

-- If you have other custom functions, apply this pattern:
--
-- ALTER FUNCTION your_function_name(args)
-- SET search_path = pg_catalog, public;
--
-- OR recreate them with SET search_path in the definition


-- Step 5: Verification query
-- =====================================================================

-- Verify the fix was applied correctly
SELECT 
  proname AS function_name,
  prosrc AS function_body,
  proconfig AS settings,
  CASE 
    WHEN proconfig IS NOT NULL AND 'search_path=pg_catalog,public' = ANY(proconfig) 
    THEN '✓ FIXED'
    ELSE '❌ STILL VULNERABLE'
  END AS status
FROM pg_proc 
WHERE proname = 'update_updated_at_column';


-- =====================================================================
-- Migration Complete
-- =====================================================================
-- After running this migration:
-- 1. Verify the fix with the verification query above
-- 2. Run the security audit query to check for other vulnerable functions
-- 3. Test your triggers to ensure they still work correctly
-- 4. Monitor Supabase lint dashboard - the warning should disappear
-- =====================================================================

