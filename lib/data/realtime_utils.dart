import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds a fresh Supabase realtime stream. Invoked once per (re)connect by
/// [resilientRealtimeStream] — must always create a brand new
/// `_client.from(...).stream(...)` chain so the underlying channel is new.
typedef RealtimeStreamFactory<T> = Stream<T> Function();

/// Wraps a Supabase realtime stream so transient socket failures
/// (`RealtimeSubscribeException` with `timedOut` or `channelError`, network
/// flicker after the app is backgrounded, OS-killed websocket on resume,
/// etc.) DON'T bubble up to Riverpod as an `AsyncError` and surface to the
/// user as "Something went wrong".
///
/// Behaviour:
///   - Forwards every value the underlying stream emits.
///   - On a transient error we cancel the dead subscription, wait with
///     exponential backoff (capped at [maxBackoff]) and re-invoke
///     [factory] to start a brand-new channel. supabase_flutter's
///     `.stream()` always does an initial PostgREST SELECT, so the UI
///     re-emits fresh data on every reconnect.
///   - The backoff resets to [initialBackoff] on the first healthy emission.
///   - Non-transient errors (e.g. PostgrestException for an RLS denial)
///     are forwarded unchanged so genuine bugs still surface.
///
/// The returned stream is single-subscription, matching Riverpod's
/// `StreamProvider` contract.
Stream<T> resilientRealtimeStream<T>(
  RealtimeStreamFactory<T> factory, {
  Duration initialBackoff = const Duration(seconds: 2),
  Duration maxBackoff = const Duration(seconds: 30),
}) {
  late StreamController<T> controller;
  StreamSubscription<T>? sub;
  Timer? reconnectTimer;
  Duration backoff = initialBackoff;
  bool closed = false;

  bool isTransient(Object e) {
    if (e is RealtimeSubscribeException) return true;
    if (e is TimeoutException) return true;
    final s = e.toString().toLowerCase();
    return s.contains('socket') ||
        s.contains('connection') ||
        s.contains('websocket') ||
        s.contains('network is unreachable');
  }

  void start() {
    if (closed) return;
    sub?.cancel();
    sub = factory().listen(
      (event) {
        backoff = initialBackoff;
        if (!controller.isClosed) controller.add(event);
      },
      onError: (Object e, StackTrace st) {
        if (isTransient(e)) {
          reconnectTimer?.cancel();
          reconnectTimer = Timer(backoff, start);
          backoff *= 2;
          if (backoff > maxBackoff) backoff = maxBackoff;
        } else {
          if (!controller.isClosed) controller.addError(e, st);
        }
      },
      onDone: () {
        if (closed) return;
        reconnectTimer?.cancel();
        reconnectTimer = Timer(backoff, start);
      },
      cancelOnError: false,
    );
  }

  controller = StreamController<T>(
    onListen: start,
    onCancel: () async {
      closed = true;
      reconnectTimer?.cancel();
      reconnectTimer = null;
      await sub?.cancel();
      sub = null;
    },
  );

  return controller.stream;
}
