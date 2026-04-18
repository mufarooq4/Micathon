import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/invitation.dart';
import '../models/profile.dart';
import '../state/profile_providers.dart';

/// Replaces the legacy `add_dependent_search9.dart` screen.
///
/// Flow:
///   1. Parent picks the role to invite (Child default) and an expiry.
///   2. Taps "Generate Invite Code" → `create_invitation` RPC.
///   3. The 8-char code is rendered XXXX-XXXX with Copy + a live countdown.
///   4. "Generate another" resets and lets them mint a new one.
///
/// The child enters the code on `PendingInviteScreen`; the realtime profile
/// stream then auto-routes them into the family. We do NOT pre-target by
/// email — keeping codes role-scoped only is simpler and matches the current
/// `invitations` schema (no `email` column).
class InviteDependentScreen extends ConsumerStatefulWidget {
  const InviteDependentScreen({super.key});

  @override
  ConsumerState<InviteDependentScreen> createState() =>
      _InviteDependentScreenState();
}

class _InviteDependentScreenState
    extends ConsumerState<InviteDependentScreen> {
  static const Color _kPrimary = Color(0xFF00502C);
  static const Color _kBackground = Color(0xFFFAF9F6);
  static const Color _kError = Color(0xFFBA1A1A);
  static const Color _kSurfaceContainer = Color(0xFFF4F3F1);
  static const Color _kStone400 = Color(0xFFA8A29E);
  static const Color _kStone700 = Color(0xFF44403C);

  static const _ttlPresets = <_TtlPreset>[
    _TtlPreset('1 hour', Duration(hours: 1)),
    _TtlPreset('24 hours', Duration(hours: 24)),
    _TtlPreset('7 days', Duration(days: 7)),
  ];

  UserRole _roleOffered = UserRole.child;
  Duration _ttl = const Duration(hours: 24);
  bool _generating = false;
  Invitation? _invite;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    // Drive the "expires in …" countdown text once a second.
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _invite != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final invite = await ref
          .read(invitationsRepositoryProvider)
          .createInvitation(roleOffered: _roleOffered, ttl: _ttl);
      if (!mounted) return;
      setState(() => _invite = invite);
    } on PostgrestException catch (e) {
      _showError(_messageForCode(e));
    } catch (e) {
      _showError('Could not generate invite: $e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _copy() async {
    final invite = _invite;
    if (invite == null) return;
    await Clipboard.setData(ClipboardData(text: invite.formattedCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied ${invite.formattedCode} to clipboard'),
          backgroundColor: _kPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _reset() => setState(() => _invite = null);

  String _messageForCode(PostgrestException e) {
    switch (e.code) {
      case '28000':
        return 'Your session expired. Please sign in again.';
      case '42501':
        return 'Only parents in a family can invite dependents.';
      case '22023':
        return e.message;
      case '40001':
        return 'Could not allocate a unique code. Please try again.';
      default:
        return e.message;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _kError,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Kafeel',
          style: TextStyle(
            color: _kPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _invite == null
              ? _buildGeneratorView()
              : _buildCodeView(_invite!),
        ),
      ),
    );
  }

  Widget _buildGeneratorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invite Dependent',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _kPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Generate a one-time code and share it with the family member you '
          'want to add. They\'ll enter it on their phone after signing up.',
          style: TextStyle(color: Color(0xFF78716C), fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 32),
        _buildSectionLabel('INVITE AS'),
        const SizedBox(height: 8),
        _buildRoleToggle(),
        const SizedBox(height: 24),
        _buildSectionLabel('CODE EXPIRES AFTER'),
        const SizedBox(height: 8),
        _buildTtlPicker(),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _generating ? null : _generate,
          icon: _generating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.qr_code_2, color: Colors.white),
          label: const Text(
            'Generate Invite Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 24),
        _buildPrivacyCard(),
      ],
    );
  }

  Widget _buildCodeView(Invitation invite) {
    final remaining = invite.expiresAt.difference(DateTime.now());
    final expired = remaining.isNegative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invite Generated',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _kPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share this code with your ${invite.roleOffered.name}. They\'ll '
          'enter it after signing up to join your family.',
          style: const TextStyle(
            color: Color(0xFF78716C),
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kSurfaceContainer),
          ),
          child: Column(
            children: [
              Text(
                invite.formattedCode,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                  fontFamily: 'monospace',
                  color: _kPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    expired ? Icons.timer_off_outlined : Icons.timer_outlined,
                    size: 16,
                    color: expired ? _kError : _kStone400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    expired
                        ? 'Expired'
                        : 'Expires in ${_formatDuration(remaining)}',
                    style: TextStyle(
                      color: expired ? _kError : _kStone700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: expired ? null : _copy,
          icon: const Icon(Icons.copy, color: Colors.white),
          label: const Text(
            'Copy Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, color: _kPrimary),
          label: const Text(
            'Generate another',
            style: TextStyle(
              color: _kPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: _kPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPrivacyCard(),
      ],
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _kSurfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRolePill(
              label: 'Child',
              role: UserRole.child,
            ),
          ),
          Expanded(
            child: _buildRolePill(
              label: 'Parent',
              role: UserRole.parent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePill({required String label, required UserRole role}) {
    final selected = _roleOffered == role;
    return GestureDetector(
      onTap: () => setState(() => _roleOffered = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _kPrimary : _kStone700,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTtlPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _ttlPresets.map((p) {
        final selected = _ttl == p.duration;
        return GestureDetector(
          onTap: () => setState(() => _ttl = p.duration),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? _kPrimary : _kSurfaceContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              p.label,
              style: TextStyle(
                color: selected ? Colors.white : _kStone700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: _kStone400,
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How invite codes work',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Anyone with this code can join your family in the role you '
                  'chose. Codes are single-use and expire automatically.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    }
    if (d.inMinutes >= 1) {
      final m = d.inMinutes;
      final s = d.inSeconds.remainder(60);
      return '${m}m ${s}s';
    }
    return '${d.inSeconds}s';
  }
}

class _TtlPreset {
  const _TtlPreset(this.label, this.duration);
  final String label;
  final Duration duration;
}
