import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_destination.dart';
import '../models/profile.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

/// How long we tolerate `session != null && profile == null` before deciding
/// the row is genuinely missing rather than just trigger-lag.
///
/// `handle_new_user` is AFTER INSERT on `auth.users`, so there is a brief
/// window where the auth event has fired but the profile row hasn't landed.
/// Two seconds is plenty for any reasonable Postgres trigger latency without
/// being annoyingly long if something is actually broken.
const _kProfileGracePeriod = Duration(seconds: 2);

/// Emits `false` immediately and `true` after [_kProfileGracePeriod].
///
/// Re-created on every session change because we watch [sessionProvider].
/// Used by [routerProvider] to decide whether `profile == null` means
/// "wait, the trigger is still firing" or "this profile is genuinely missing".
final _profileGraceElapsedProvider = StreamProvider<bool>((ref) {
  ref.watch(sessionProvider);
  return Stream<bool>.fromFuture(
    Future<bool>.delayed(_kProfileGracePeriod, () => true),
  ).startWith(false);
});

extension _StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T initial) async* {
    yield initial;
    yield* this;
  }
}

/// Single source of truth for which top-level screen the app should show.
///
/// Pure derivation, no IO. The router widget in `main.dart` watches this and
/// switches on the result. When `redeem_invitation` or `create_family` runs,
/// the streamed profile updates, this re-derives, and the router auto-routes
/// to the new home — no `Navigator.push` needed anywhere in onboarding.
final routerProvider = Provider<AppDestination>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return const UnauthDestination();
  }

  final profileAsync = ref.watch(myProfileProvider);

  return profileAsync.when(
    loading: () => const SplashDestination(),
    error: (err, _) => ProfileErrorDestination(err.toString()),
    data: (profile) {
      if (profile == null) {
        // Trigger lag: hold on Splash for the grace period, then declare the
        // row genuinely missing.
        final graceElapsed =
            ref.watch(_profileGraceElapsedProvider).value ?? false;
        if (!graceElapsed) {
          return const SplashDestination();
        }
        return const ProfileErrorDestination(
          'We could not find your profile. Please sign out and try again.',
        );
      }
      return _destinationForProfile(profile);
    },
  );
});

AppDestination _destinationForProfile(Profile profile) {
  // Anyone without a family — regardless of role — needs onboarding.
  // Covers fresh signups (role=pending), legacy children created before the
  // under-18 trigger update (role=child + family_id=null), and any future
  // orphaned-state we haven't anticipated. PendingInviteScreen offers both
  // the join (invite code) and create (new family) paths.
  if (profile.familyId == null) {
    return const PendingInviteDestination();
  }

  switch (profile.role) {
    case UserRole.parent:
      return const ParentHomeDestination();
    case UserRole.child:
      return const ChildHomeDestination();
    case UserRole.pending:
      // Pending with a family_id shouldn't be reachable, but if it ever is,
      // surface it as an error rather than silently picking a home.
      return const ProfileErrorDestination(
        'Your account is in an inconsistent state (pending with a family). '
        'Please sign out and try again.',
      );
    case UserRole.unknown:
      return const ProfileErrorDestination(
        'Your account has an unknown role. Please contact support.',
      );
  }
}
