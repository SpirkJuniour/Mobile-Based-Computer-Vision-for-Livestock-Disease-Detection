# ⚡ QUICK SUPABASE REVERT GUIDE

**Date:** November 3, 2025  
**Time Required:** 5 minutes  

## 🎯 Quick Steps to Revert Everything

### Step 1: Revert Database Changes (2 minutes)

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard/project/slkihxgkafkzasnpjmbl
   - Click: **SQL Editor** → **New Query**

2. **Run Revert SQL**
   - Copy all contents from: `supabase_migrations/REVERT_001_fix_function_search_path.sql`
   - Paste into SQL Editor
   - Click **"Run"** or press `Ctrl+Enter`
   - Should see: "Success. No rows returned"

### Step 2: Disable MFA (1 minute)

1. **In Supabase Dashboard**
   - Go to: **Authentication** → **Settings**
   - Scroll to: **"Multi-Factor Authentication"** section
   - Toggle OFF: **"Enable TOTP"**
   - Click **"Save"**

### Step 3: Disable Password Protection (1 minute)

1. **In Same Settings Page**
   - Scroll to: **"Password Protection"** or **"Security"** section
   - Toggle OFF: **"Leaked password protection"**
   - Reset password length to: **6** (from 12)
   - Click **"Save"**

### Step 4: Reset Email Settings (Optional - 1 minute)

If you changed email/SMTP settings:
1. Go to: **Authentication** → **Email Templates**
2. Scroll to: **"SMTP Settings"**
3. Click **"Use Supabase SMTP"** (default)
4. Click **"Save"**

## ✅ Done!

Your Supabase is now back to its original state before today's changes.

### Verify Everything is Reverted:
- [ ] SQL migration reverted (function no longer has fixed search_path)
- [ ] MFA disabled
- [ ] Password protection disabled
- [ ] Email settings reset (if changed)

---

**Total Time:** ~5 minutes  
**Need Help?** Check Supabase logs: Dashboard → Logs → Database Logs

