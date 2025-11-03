-- =====================================================================
-- REVERT SQL Migration: Restore Original Function (Before Fix)
-- =====================================================================
-- This reverts the search_path fix and restores the original function
-- Run this in Supabase SQL Editor to undo the changes
-- =====================================================================

-- Drop the fixed function
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

-- Recreate the original function WITHOUT the fixed search_path
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- Recreate triggers
CREATE TRIGGER set_updated_at_users
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_livestock
  BEFORE UPDATE ON public.livestock
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_diagnoses
  BEFORE UPDATE ON public.diagnoses
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_diseases
  BEFORE UPDATE ON public.diseases
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Done - function reverted to original state

