/// Supabase project configuration.
///
/// Replace the values below with the credentials from your Supabase
/// project's "Settings → API" page:
///   - `url`     -> "Project URL"
///   - `anonKey` -> "anon public" key
///
/// Tip: do NOT commit real keys to a public repo. Either keep this file
/// out of version control via `.gitignore`, or pass them at build time
/// using `--dart-define=SUPABASE_URL=...` and read them with
/// `String.fromEnvironment('SUPABASE_URL')`.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT-REF.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR-SUPABASE-ANON-KEY',
  );
}
