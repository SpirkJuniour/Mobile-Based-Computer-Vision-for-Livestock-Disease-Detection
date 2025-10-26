/// Supabase Configuration
///
/// To set up Supabase:
/// 1. Create a project at https://supabase.com
/// 2. Get your project URL and anon key from Project Settings > API
/// 3. Replace the placeholder values below
///
/// For production, consider using environment variables or flutter_dotenv
library;

class SupabaseConfig {
  /// Your Supabase project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://slkihxgkafkzasnpjmbl.supabase.co',
  );

  /// Your Supabase anon/public key
  /// For production, use environment variables: flutter run --dart-define=SUPABASE_KEY=your_key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsa2loeGdrYWZremFzbnBqbWJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNTQwNDAsImV4cCI6MjA3NTczMDA0MH0.l3zg4YCbttVJecxC7ESPj_up1TyX6Rv0f6sei4dJsZM',
  );

  /// Optional: Enable debug mode for development
  static const bool debugMode = true;

  /// Optional: Configure auth settings
  static const bool persistSession = true;

  /// Optional: Auto refresh token settings
  static const bool autoRefreshToken = true;
}
