# Kafeel — Family Finance

A **family-first neobank ledger** built for parents and their dependents. Parents
invite their kids into a shared "family tree", set monthly spending limits and
weekly auto-allowances, and approve borrow/loan requests in real time. Kids see
their balance, log outside-the-family expenses, and request money from a
sibling or parent.

Built with **Flutter + Riverpod** on the client and **Supabase
(Postgres + Auth + Realtime + RLS + RPC)** on the server. All money math
happens server-side inside SQL transactions — the client never edits a balance.

> Internal codename: `micathon` (Flutter package name). User-facing name: **Kafeel**.

---

## Table of contents

1. [Highlights](#highlights)
2. [Screenshots](#screenshots)
3. [Architecture](#architecture)
4. [Tech stack](#tech-stack)
5. [Project structure](#project-structure)
6. [Getting started](#getting-started)
7. [Supabase setup](#supabase-setup)
8. [Database schema & RPCs](#database-schema--rpcs)
9. [Money handling rules](#money-handling-rules)
10. [Realtime resilience](#realtime-resilience)
11. [Branding (icon & splash)](#branding-icon--splash)
12. [Common dev tasks](#common-dev-tasks)
13. [Roadmap](#roadmap)

---

## Highlights

- **Two roles, one app.** Parents administer; children transact within the
  rails parents define. The router (`lib/state/router_provider.dart`) derives
  the home screen purely from the streamed `profiles` row — no manual
  `Navigator.pushReplacement` after sign-in.
- **Atomic money movement.** `transfer_money`, `act_on_request`, and
  `log_expense` are `SECURITY DEFINER` RPCs that debit + credit + insert the
  ledger row inside a single transaction. The client only ever calls RPCs.
- **Live everywhere.** Balances, family roster, pending requests, transactions,
  and parent-set limits all stream via Supabase Realtime, wrapped in a
  resilient reconnecting helper (`lib/data/realtime_utils.dart`).
- **Server-enforced spending controls.** Parents move a slider; the
  `enforce_monthly_limit(child_id, amount)` Postgres function rejects any
  `transfer_money` / `log_expense` that would push month-to-date spending past
  the cap. The UI mirrors this calculation to render a live progress bar and
  to soft-validate before submitting.
- **Outside-family expenses.** A floating `+` opens an "Add expense" screen —
  amount + free-text description + category picker (groceries, dining,
  entertainment, transport, …). The expense lands in the same `transactions`
  ledger as transfers (discriminated by `kind`).
- **Pixel-true money.** All amounts are `BIGINT` minor units (paisas) on the
  server and `BigInt` on the client, formatted at the UI boundary by
  `lib/models/money.dart`.

---

## Screenshots

> Run the app on an Android emulator (`flutter run -d emulator-5554`) to see:
> - dark-green balance hero with subtle geometric pattern + centered
>   **Send Money** CTA
> - Pending Requests with an "N New" pill badge and Approve / Decline cards
> - Spending Limits — Monthly Limit card with a live progress bar, Weekly
>   Allowance card with a piggy-bank badge, stacked vertically
> - Add Expense floating action button on both home screens
> - Animated brand splash that hands off seamlessly from the native splash

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter App (lib/)                                         │
│                                                             │
│   screens/   ──────► widgets/ ──────► models/               │
│      ▲                                                      │
│      │ ref.watch                                            │
│      ▼                                                      │
│   state/  (Riverpod providers)                              │
│      ▲                                                      │
│      │ stream / future                                      │
│      ▼                                                      │
│   data/   (Supabase repositories + resilient streams)       │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTPS + WSS
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Supabase                                                   │
│   • Auth (email/password)                                   │
│   • Postgres                                                │
│       families · profiles · invitations · transactions      │
│       requests · dependent_controls                         │
│   • Realtime (WAL → WebSocket)                              │
│   • RPCs:  transfer_money · act_on_request · log_expense    │
│            redeem_invitation · create_family · …            │
│   • RLS policies key everything off family_id               │
└─────────────────────────────────────────────────────────────┘
```

### Architectural rules (taken from `plan.md`, kept honest)

1. **Database is the source of truth.** Money is `BIGINT` on the server and
   `BigInt` on the client. The client never mutates a balance directly.
2. **Riverpod everywhere.** Global state (auth session, profile, family,
   transactions, requests, controls) lives in `lib/state/*_providers.dart`.
   Only ephemeral, single-screen UI state uses `setState`.
3. **Single root Navigator.** `MicathonApp` owns the only `MaterialApp`. The
   `_Router` widget switches on `routerProvider`. New screens are pushed onto
   the root navigator (`Navigator.of(context, rootNavigator: true).push(…)`),
   never onto a nested one.
4. **Families are first-class.** Every row in `profiles`, `transactions`,
   `requests`, `dependent_controls`, and `invitations` carries a `family_id`,
   and that's the column RLS keys off.

---

## Tech stack

| Layer            | Choice                                 | Why                                              |
| ---------------- | -------------------------------------- | ------------------------------------------------ |
| UI               | Flutter (Material 3)                   | Single codebase, hot reload                      |
| State            | `flutter_riverpod` ^2.6                | Stream-friendly, compile-time-safe DI            |
| Backend          | Supabase                               | Postgres + Auth + Realtime + RLS in one box      |
| Auth             | `supabase_flutter` ^2.12               | Email/password, session persistence              |
| Realtime         | Supabase Realtime + custom resilience  | Auto-reconnect with exponential backoff          |
| Money            | `BigInt` (minor units)                 | No float drift, matches Postgres `BIGINT`        |
| Splash + icon    | `flutter_native_splash`, `flutter_launcher_icons` | Generated once, baked into platform assets |

Deps live in `pubspec.yaml`. Dart SDK constraint: `^3.11.5`.

---

## Project structure

```
lib/
├── main.dart                       # MaterialApp + router switch
├── supabase_config.dart            # URL / anon key (override via --dart-define)
│
├── data/                           # Supabase repositories
│   ├── profiles_repository.dart
│   ├── family_repository.dart
│   ├── requests_repository.dart
│   ├── transactions_repository.dart
│   ├── dependent_controls_repository.dart
│   ├── invitations_repository.dart
│   └── realtime_utils.dart         # resilientRealtimeStream() helper
│
├── models/                         # Plain Dart value objects + enums
│   ├── profile.dart
│   ├── money.dart                  # format / parseMajorToMinor
│   ├── transaction.dart            # LedgerEntry (transfer | expense)
│   ├── expense_category.dart       # enum + display name + icon
│   ├── money_request.dart
│   ├── dependent_controls.dart
│   ├── invitation.dart
│   └── app_destination.dart        # sealed router destinations
│
├── state/                          # Riverpod providers
│   ├── auth_providers.dart
│   ├── profile_providers.dart
│   ├── family_providers.dart       # family roster + transactions + requests
│   └── router_provider.dart        # derives top-level destination
│
├── widgets/                        # Reusable UI bits
│   ├── add_expense_fab.dart
│   ├── ledger_list.dart
│   └── avatar_utils.dart
│
└── screens/                        # One file per top-level screen
    ├── splash_screen.dart          # animated brand splash
    ├── login0.dart   /  signup.dart
    ├── pending_invite_screen.dart  # join family OR create one
    ├── parent_home1.dart           # parent dashboard
    ├── childhome5.dart             # child dashboard
    ├── Sendmoney12.dart            # send money flow
    ├── Monereq13.dart              # request money flow
    ├── add_expense_screen.dart     # log outside-family spend
    ├── ViewFamilyMemberChild8.dart # parent → child detail + controls
    ├── manage_dependent4.dart      # parent's dependents list
    ├── invite_dependent_screen.dart
    ├── parent_view_family_tree3.dart
    ├── child_view_of_family_tree7.dart
    ├── Familyactivity2.dart  /  child_activity6.dart   # ledger views
    ├── add_dependent_search9.dart
    ├── add_dependent_configuration10.dart
    ├── dependent_approval11.dart
    └── settings_screen.dart

supabase/
└── migrations/
    └── 20260419120000_add_expense_kind.sql

assets/
└── app_logo.png                    # source image for icon + splash

android/
└── app/                            # native launcher icons + splash drawables
                                    # (regenerated by the icon/splash tools)
```

---

## Getting started

### Prerequisites

- **Flutter** ≥ 3.24 (Dart SDK ≥ 3.11.5)
- **Android SDK** with an emulator or a USB-debug device
  *(iOS/web aren't configured yet — see [Roadmap](#roadmap))*
- A **Supabase project** (free tier is fine)

### 1. Clone and install

```bash
git clone <your-repo-url> micathon
cd micathon
flutter pub get
```

### 2. Point the app at your Supabase project

Open `lib/main.dart` and replace the `Supabase.initialize` `url` and `anonKey`
with your own values, **or** prefer the safer `--dart-define` route which
`lib/supabase_config.dart` already reads:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=ey...
```

Your project URL and anon key live under **Supabase → Project Settings → API**.

### 3. Apply the database schema

See [Supabase setup](#supabase-setup) below. At minimum you need the base
tables/RLS/RPCs (parent codebase task — not in `supabase/migrations/` yet) plus
the expense migration:

```text
supabase/migrations/20260419120000_add_expense_kind.sql
```

Paste it into **Supabase → SQL Editor → New query → Run**.

### 4. Run

```bash
flutter devices            # pick a device id
flutter run -d emulator-5554
```

You should see the cream native splash → the in-app animated splash → the
login screen.

---

## Supabase setup

The app expects the following tables to exist (column types simplified):

| Table                   | Key columns                                                                                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------ |
| `families`              | `id uuid pk`, `name text`                                                                                    |
| `profiles`              | `id uuid pk → auth.users`, `family_id uuid`, `role user_role`, `balance bigint`, `full_name`, `email`, `dob` |
| `invitations`           | `id`, `family_id`, `code text unique`, `role_offered`, `expires_at`, `redeemed_by`                           |
| `transactions`          | `id`, `family_id`, `sender_id`, `receiver_id` *(nullable for expenses)*, `amount bigint`, `kind`, `description`, `category`, `created_at` |
| `requests`              | `id`, `requester_id`, `approver_id`, `amount bigint`, `status` (`pending` → `approved` / `declined`)         |
| `dependent_controls`    | `child_id`, `monthly_limit_minor bigint`, `auto_transfer_enabled`, `auto_transfer_amount_minor`, `auto_transfer_day` (Postgres dow: 0=Sun…6=Sat) |

Required Postgres enums: `user_role` (`pending`, `child`, `parent`).

Required RPCs (all `SECURITY DEFINER`, called from `lib/data/*_repository.dart`):

- `transfer_money(receiver uuid, amount bigint)` — atomic peer-to-peer transfer
- `act_on_request(request_id uuid, action text)` — approve/decline a request
- `log_expense(amount bigint, description text, category text)` — outside-family spend (in `supabase/migrations/`)
- `redeem_invitation(code text)` — join a family
- `create_family(name text)` — bootstrap as parent
- `enforce_monthly_limit(child_id uuid, amount bigint)` — internal helper used by `transfer_money` and `log_expense`

Required Realtime publications: enable Realtime on `profiles`, `transactions`,
`requests`, `dependent_controls`, and (optionally) `families` for live family
roster updates.

Required RLS: every table's `SELECT` policy keys off
`family_id = (select family_id from profiles where id = auth.uid())`. The
expense migration relies on this — adding `kind = 'expense'` rows doesn't
require a new policy because they're scoped by `family_id` like everything else.

> The base schema/policies/RPCs predate the migration runner, so they were
> originally pasted into the SQL Editor by hand (per `plan.md` §6.2). Going
> forward, drop new SQL into `supabase/migrations/` with an
> `YYYYMMDDHHMMSS_*.sql` prefix and apply it the same way until a CLI runner
> lands.

---

## Database schema & RPCs

### `transactions` (the immutable ledger)

A single table holds **two kinds** of rows, discriminated by the `kind` column:

| `kind`     | `sender_id` | `receiver_id` | `description` | `category` |
| ---------- | ----------- | ------------- | ------------- | ---------- |
| `transfer` | required    | **required**  | null          | null       |
| `expense`  | required    | **null**      | required      | required   |

A `CHECK` constraint (`transactions_kind_shape_check` in
`20260419120000_add_expense_kind.sql`) enforces this at the database level. The
ledger is append-only — never `UPDATE` or `DELETE`.

### `log_expense` flow

Tap **+ → Add expense** on either home screen → fill amount + description +
category → Save:

1. Client calls `transactions_repository.logExpense(...)` which RPCs
   `public.log_expense(p_amount, p_description, p_category)`.
2. The RPC validates input, locks the caller's `profiles` row, calls
   `enforce_monthly_limit` if the caller is a child, decrements `balance`, and
   inserts the `kind='expense'` ledger row — all inside one transaction.
3. Realtime pushes the updated profile + the new transaction to every family
   member, so the balance and recent activity refresh automatically.

### `transfer_money` flow

`Send Money` → pick recipient → confirm. Same shape as above, but the RPC
debits sender + credits receiver in one transaction and inserts a
`kind='transfer'` row.

### `act_on_request` flow

A request lives in `requests` with `status='pending'`. When the approver hits
**Approve**, `act_on_request` calls `transfer_money` internally and flips the
status. **Decline** just flips the status.

---

## Money handling rules

> If you take one thing from this README, take this.

- **Server-side**: every amount column is `BIGINT`, in **paisas** (1 PKR = 100
  paisas).
- **Client-side**: every amount is a `BigInt`. We never use `double`/`num` for
  money. Display formatting goes through `Money.format(BigInt minor, {currency})`,
  parsing goes through `Money.parseMajorToMinor(String)`.
- **Mutations** only happen via RPC. There is no `client.from('profiles').update({balance: ...})`
  anywhere in the codebase, by design.
- **Validation** is duplicated for UX: the client soft-validates (e.g.
  "would-this-exceed-monthly-limit" preflight in `_wouldExceedMonthlyLimit`),
  but the server is the gate that says yes/no.

---

## Realtime resilience

Supabase Realtime occasionally throws `RealtimeSubscribeException(timedOut)`
on backgrounded or flaky connections. To keep the UI honest, every
repository wraps its `client.stream(...)` in
`resilientRealtimeStream(...)` from `lib/data/realtime_utils.dart`:

- Transient errors (`RealtimeSubscribeException`, `TimeoutException`, common
  network strings) trigger a silent reconnect with **exponential backoff**
  (2s → 4s → 8s → … capped at 30s).
- Real errors are forwarded to the stream consumer.
- The default Supabase Realtime timeout is bumped from 10s → 30s in
  `Supabase.initialize` to reduce false positives in the first place.

The result: a child can lock the phone, get on a different Wi-Fi, unlock, and
the parent's slider movements still surface without a manual pull-to-refresh.

---

## Branding (icon & splash)

The brand mark lives at `assets/app_logo.png`. Two generators turn it into
platform assets:

```bash
# App launcher icon (mipmaps + adaptive icon for Android 8+)
dart run flutter_launcher_icons

# Native pre-Flutter splash (drawable + Android 12+ Splashscreen API)
dart run flutter_native_splash:create
```

Both are configured at the bottom of `pubspec.yaml`. After regenerating, do a
**full uninstall + reinstall** on the device — Android caches launcher icons
and splash drawables aggressively, so a hot-reload won't refresh them.

The in-app `SplashScreen` (`lib/screens/splash_screen.dart`) shows the same
logo with a 900 ms fade-in + scale-up so the OS-level splash visually flows
into the Flutter UI with no jump.

---

## Common dev tasks

```bash
# Install deps
flutter pub get

# Static analysis
flutter analyze lib

# Run on a specific device (find one via `flutter devices`)
flutter run -d emulator-5554

# Build a debug APK
flutter build apk --debug

# Build a release APK
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=ey...

# Refresh launcher icons after editing assets/app_logo.png
dart run flutter_launcher_icons

# Refresh native splash after editing assets/app_logo.png
dart run flutter_native_splash:create

# Wipe build artefacts if things get weird
flutter clean && flutter pub get
```

In a `flutter run` session: **r** = hot reload, **R** = hot restart,
**q** = quit.

---

## Roadmap

Things that are intentionally not done yet:

- **iOS + web targets.** Both icon/splash configs are set to `ios: false` /
  `web: false`. Flip them on and re-run the generators when the iOS bundle is
  configured in Xcode.
- **CLI migration runner.** SQL still flows through the Supabase SQL Editor.
  Wire up `supabase` CLI + `supabase db push` so `supabase/migrations/*.sql`
  applies automatically in CI.
- **Auto-allowance executor.** `dependent_controls.auto_transfer_*` columns
  exist; the scheduled job that actually fires the weekly transfer is still
  TODO. (`pg_cron` is the obvious home for it.)
- **Loading spinners on Approve/Decline.** Approve already shows a spinner;
  the redesign prompt floated adding the same to Decline + a swipeable
  triage card for mobile.
- **Push notifications** for new requests + balance changes.
- **End-to-end and golden tests.** Right now we lean on `flutter analyze` and
  manual emulator testing.

PRs welcome on any of the above.
