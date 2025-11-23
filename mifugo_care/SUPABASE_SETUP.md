# Supabase Setup Guide for Mifugo Care

## Current Status
- **Last App Update**: November 20, 2025 (4:16 PM)
- **Models Ready**: ✅ Both ONNX models in `assets/models/`
- **Supabase Status**: ⚠️ Needs configuration (using placeholder values)

## Step-by-Step Supabase Setup

### 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click **"New Project"**
4. Fill in the project details:
   - **Name**: `mifugo-care` (or your preferred name)
   - **Database Password**: Create a strong password (save it!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier is sufficient for development

### 2. Get Your Supabase Credentials

Once your project is created:

1. Go to **Settings** → **API** in your Supabase dashboard
2. You'll find:
   - **Project URL**: `https://YOUR-PROJECT-REF.supabase.co`
   - **anon/public key**: A long string starting with `eyJ...`

**⚠️ Important**: Keep these credentials secure!

### 3. Configure the Flutter App

You have **3 options** to configure Supabase in your app:

#### Option A: Environment Variables (Recommended for Production)

Create a `.env` file in the project root (add to `.gitignore`):

```env
SUPABASE_URL=https://YOUR-PROJECT-REF.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

Then run the app with:
```bash
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

#### Option B: Direct Configuration (Quick Testing)

Edit `lib/main.dart` and replace the placeholder values:

```dart
await Supabase.initialize(
  url: 'https://YOUR-PROJECT-REF.supabase.co',  // Replace with your URL
  anonKey: 'your_anon_key_here',                 // Replace with your key
);
```

**⚠️ Warning**: Don't commit this to version control! Use environment variables for production.

#### Option C: Configuration File (Development)

Create `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR-PROJECT-REF.supabase.co';
  static const String anonKey = 'your_anon_key_here';
}
```

Then update `lib/main.dart`:

```dart
import 'config/supabase_config.dart';

await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

**⚠️ Add `lib/config/supabase_config.dart` to `.gitignore`!**

### 4. Set Up Database Tables

Run these SQL commands in your Supabase SQL Editor:

#### Users Table
```sql
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

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);
```

#### Livestock Table
```sql
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

ALTER TABLE livestock ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Farmers can manage own livestock" ON livestock
  FOR ALL USING (auth.uid() = farmer_id);
```

#### Diagnoses Table
```sql
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

ALTER TABLE diagnoses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Farmers can manage own diagnoses" ON diagnoses
  FOR ALL USING (auth.uid() = farmer_id);

CREATE POLICY "Vets can read all diagnoses" ON diagnoses
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'veterinarian')
  );

CREATE POLICY "Vets can update diagnoses" ON diagnoses
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'veterinarian')
  );
```

#### Vet Cases Table
```sql
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

ALTER TABLE vet_cases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Vets can manage own cases" ON vet_cases
  FOR ALL USING (auth.uid() = vet_id);

CREATE POLICY "Farmers can read own cases" ON vet_cases
  FOR SELECT USING (auth.uid() = farmer_id);
```

#### Notifications Table
```sql
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);
```

### 5. Set Up Storage Buckets

1. Go to **Storage** in your Supabase dashboard
2. Create these buckets:

#### `livestock_images`
- **Public**: ✅ Yes
- **File size limit**: 5 MB
- **Allowed MIME types**: `image/jpeg, image/png, image/webp`

#### `diagnosis_images`
- **Public**: ✅ Yes
- **File size limit**: 10 MB
- **Allowed MIME types**: `image/jpeg, image/png, image/webp`

#### Storage Policies

For each bucket, add these policies:

```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'livestock_images' AND
    auth.role() = 'authenticated'
  );

-- Allow public read access
CREATE POLICY "Public can read images" ON storage.objects
  FOR SELECT USING (bucket_id = 'livestock_images');
```

### 6. Enable Authentication

1. Go to **Authentication** → **Providers** in Supabase
2. Enable:
   - ✅ **Email** (default, already enabled)
   - ✅ **Google** (optional, for OAuth)
   - ✅ **Apple** (optional, for iOS)

### 7. Test the Connection

Create a test file `test_supabase.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );

  final client = Supabase.instance.client;
  
  // Test connection
  try {
    final response = await client.from('users').select().limit(1);
    print('✅ Supabase connected successfully!');
    print('Response: $response');
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}
```

Run it:
```bash
dart test_supabase.dart
```

### 8. Verify App Integration

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Try to:
   - Sign up a new user
   - Sign in
   - Check if data is saved in Supabase dashboard

3. Check Supabase Dashboard:
   - **Table Editor**: Should show your tables
   - **Authentication**: Should show registered users
   - **Storage**: Should show uploaded images

## Troubleshooting

### Connection Issues

**Error**: "Invalid API key"
- ✅ Check that your anon key is correct
- ✅ Make sure you're using the **anon/public** key, not the service_role key

**Error**: "Failed to connect"
- ✅ Verify your Supabase URL is correct
- ✅ Check your internet connection
- ✅ Ensure your Supabase project is active

### Authentication Issues

**Error**: "Email already registered"
- ✅ User exists, try signing in instead
- ✅ Or reset password

**Error**: "Invalid credentials"
- ✅ Check email/password are correct
- ✅ Verify email is confirmed (check Supabase Auth settings)

### Database Issues

**Error**: "relation does not exist"
- ✅ Run the SQL scripts above to create tables
- ✅ Check table names match `AppConstants` in your code

**Error**: "permission denied"
- ✅ Check Row Level Security policies are set up correctly
- ✅ Verify user is authenticated

## Security Best Practices

1. **Never commit credentials to Git**
   - Use environment variables
   - Add `.env` and config files to `.gitignore`

2. **Use Row Level Security (RLS)**
   - All tables should have RLS enabled
   - Create appropriate policies for each table

3. **Use anon key, not service_role key**
   - The anon key is safe for client-side use
   - Service role key should NEVER be in client code

4. **Enable email confirmation** (optional but recommended)
   - Go to Authentication → Settings
   - Enable "Confirm email"

## Next Steps

1. ✅ Set up Supabase project
2. ✅ Configure credentials in app
3. ✅ Create database tables
4. ✅ Set up storage buckets
5. ✅ Test connection
6. ✅ Start using the app!

## Support

- Supabase Docs: https://supabase.com/docs
- Flutter Supabase: https://supabase.com/docs/guides/getting-started/flutter
- Project Issues: Check your project's issue tracker


