/// Sealed routing state derived from the current auth session and profile.
///
/// Computed in `routerProvider` and consumed by the root router widget in
/// `main.dart`. Widgets MUST use a `switch` over this so the compiler enforces
/// exhaustive handling whenever a new destination is added.
sealed class AppDestination {
  const AppDestination();
}

/// No active Supabase session: show the login / signup toggle.
class UnauthDestination extends AppDestination {
  const UnauthDestination();
}

/// Session present, but profile data isn't ready yet (initial load OR the
/// brief race between `auth.users` insert and the `handle_new_user` trigger).
class SplashDestination extends AppDestination {
  const SplashDestination();
}

/// Authenticated user with `role = 'pending'` and no `family_id`.
/// Show the "Create Family / Enter Invite Code" screen.
class PendingInviteDestination extends AppDestination {
  const PendingInviteDestination();
}

/// Authenticated parent with a valid family.
class ParentHomeDestination extends AppDestination {
  const ParentHomeDestination();
}

/// Authenticated child with a valid family.
class ChildHomeDestination extends AppDestination {
  const ChildHomeDestination();
}

/// Profile lookup errored out, returned an unrecognised role, or returned an
/// inconsistent state (e.g. role=parent but family_id is null).
class ProfileErrorDestination extends AppDestination {
  const ProfileErrorDestination(this.message);
  final String message;
}
