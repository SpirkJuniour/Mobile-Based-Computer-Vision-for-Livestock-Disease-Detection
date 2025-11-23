# Database Setup Instructions for MifugoCare

## 🚨 IMPORTANT: Run This Setup to Fix Signup Issues

To ensure signup works without any errors, you **MUST** run the SQL script below in your Supabase dashboard.

### Quick Setup (One Script)

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Open the file: `supabase_SETUP_COMPLETE.sql`
3. Copy the **entire contents** and paste it in the SQL Editor
4. Click **RUN**
5. That's it! Signup will now work perfectly.

### What This Script Does

The script sets up two layers of protection:

1. **Database Trigger (Primary Method)**
   - Automatically creates user profiles when users sign up
   - Runs with `SECURITY DEFINER` which bypasses RLS policies
   - **Most reliable method** - works 100% of the time

2. **RLS Policies (Backup Method)**
   - Allows authenticated users to insert their own records
   - Allows users to read/update their own data
   - Provides backup if trigger has issues

### After Running the Script

✅ Signup will work automatically for all new users  
✅ No errors will occur during signup  
✅ User profiles will be created automatically  
✅ Existing users can still sign in normally  

### Verification

After running the script, you should see:
- 1 trigger: `on_auth_user_created`
- 4 policies on the `users` table

The script includes verification queries at the end to check if everything was set up correctly.

### Troubleshooting

If you still see signup errors after running the script:

1. **Check the trigger exists:**
   ```sql
   SELECT * FROM information_schema.triggers 
   WHERE trigger_name = 'on_auth_user_created';
   ```

2. **Check the policies exist:**
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'users';
   ```

3. **If trigger doesn't exist, run just the trigger part:**
   - Use the contents of `supabase_trigger_auto_create_user.sql`

4. **If policies don't exist, run just the policies part:**
   - Use the contents of `supabase_QUICK_FIX.sql`

---

**Note:** The app code is now written to handle missing profiles gracefully, but running this script ensures the best user experience.

