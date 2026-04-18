import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/auth_providers.dart';
import '../state/profile_providers.dart';

/// Onboarding screen shown to authenticated users whose profile has
/// `role = 'pending'` and `family_id = null`.
///
/// Two paths forward:
///   1. Enter an invite code → `redeem_invitation` RPC → joins existing family.
///   2. Create a new family → `create_family` RPC → becomes a parent.
///
/// On either success, the streamed `myProfileProvider` emits the new row,
/// `routerProvider` re-derives, and the root router widget swaps in the
/// appropriate home screen automatically. This screen never calls Navigator.
class PendingInviteScreen extends ConsumerStatefulWidget {
  const PendingInviteScreen({super.key});

  @override
  ConsumerState<PendingInviteScreen> createState() =>
      _PendingInviteScreenState();
}

class _PendingInviteScreenState extends ConsumerState<PendingInviteScreen> {
  static const Color _kBackground = Color(0xFFFAF9F6);
  static const Color _kPrimary = Color(0xFF00502C);
  static const Color _kError = Color(0xFFBA1A1A);
  static const Color _kOnSurface = Color(0xFF1A1C1A);
  static const Color _kOnSurfaceVariant = Color(0xFF3F4941);
  static const Color _kSurfaceContainer = Color(0xFFF4F3F1);

  final _inviteController = TextEditingController();
  bool _redeeming = false;
  bool _creating = false;

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _inviteController.text.trim();
    if (code.isEmpty) {
      _showError('Please enter your invite code.');
      return;
    }
    setState(() => _redeeming = true);
    try {
      await ref.read(invitationsRepositoryProvider).redeemInvitation(code);
      // No navigation: routerProvider re-derives when the profile stream emits.
    } on PostgrestException catch (e) {
      _showError(_messageForCode(e));
    } catch (e) {
      _showError('Could not redeem invite: $e');
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _createFamily() async {
    final name = await _promptForFamilyName();
    if (name == null || name.trim().isEmpty) return;
    setState(() => _creating = true);
    try {
      await ref.read(profilesRepositoryProvider).createFamily(name.trim());
      // No navigation: routerProvider re-derives when the profile stream emits.
    } on PostgrestException catch (e) {
      _showError(_messageForCode(e));
    } catch (e) {
      _showError('Could not create family: $e');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<String?> _promptForFamilyName() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create new family'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Family name (e.g. Khan Family)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  String _messageForCode(PostgrestException e) {
    switch (e.code) {
      case 'P0002':
        return 'That invite code is not valid.';
      case '22023':
        return e.message;
      case '28000':
        return 'Your session expired. Please sign in again.';
      case '42501':
        return e.message;
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

  Future<void> _signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final fullName = profileAsync.value?.fullName ?? '';
    final greetingName = fullName.isEmpty ? 'there' : fullName.split(' ').first;
    final busy = _redeeming || _creating;

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Kafeel',
                    style: TextStyle(
                      color: _kPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome, $greetingName',
                style: const TextStyle(
                  color: _kOnSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'re almost there. Join an existing family with an invite '
                'code, or create a new family if you\'re the parent setting '
                'this up.',
                style: TextStyle(
                  color: _kOnSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildJoinCard(busy: busy),
              const SizedBox(height: 16),
              _buildCreateCard(busy: busy),
              const SizedBox(height: 32),
              TextButton(
                onPressed: busy ? null : _signOut,
                style: TextButton.styleFrom(foregroundColor: _kPrimary),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCard({required bool busy}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.group_add_outlined, color: _kPrimary),
              SizedBox(width: 8),
              Text(
                'Join a family',
                style: TextStyle(
                  color: _kOnSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Got an invite code from a parent? Enter it below.',
            style: TextStyle(
              color: _kOnSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inviteController,
            enabled: !busy,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Invite code',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: busy ? null : _redeem,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _redeeming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Enter Invite Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard({required bool busy}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kSurfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.add_home_outlined, color: _kPrimary),
              SizedBox(width: 8),
              Text(
                'Start a new family',
                style: TextStyle(
                  color: _kOnSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Setting up Kafeel for the first time? Create a new family and '
            'invite your dependents later.',
            style: TextStyle(
              color: _kOnSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: busy ? null : _createFamily,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: _kPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _creating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_kPrimary),
                    ),
                  )
                : const Text(
                    'Create New Family',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
