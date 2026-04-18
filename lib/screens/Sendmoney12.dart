import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/models/transaction.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/avatar_utils.dart';

class AppColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color primary = Color(0xFF00502C);
  static const Color primaryFixed = Color(0xFF9DF6B9);
  static const Color onPrimaryFixed = Color(0xFF00210F);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F1);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC4E9CC);
  static const Color onSecondaryContainer = Color(0xFF4A6A53);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);
  static const Color error = Color(0xFFBA1A1A);
}

/// Send money flow.
///
/// Pass [initialRecipient] when invoked from a profile screen (e.g.
/// `ViewFamilyMemberChild`). When null, the user picks from a family list.
class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key, this.initialRecipient});

  final Profile? initialRecipient;

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  Profile? _recipient;
  bool _busy = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _recipient = widget.initialRecipient;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_recipient != null) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _addQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
      _amountError = null;
    });
  }

  Future<void> _submit() async {
    final me = ref.read(myProfileProvider).asData?.value;
    final recipient = _recipient;
    if (me == null) return;
    if (recipient == null) {
      setState(() => _amountError = 'Pick a recipient first.');
      return;
    }
    final amount = Money.parseMajorToMinor(_amountController.text);
    if (amount == null) {
      setState(() => _amountError = 'Enter a positive amount (e.g. 250 or 250.00).');
      return;
    }
    if (amount > me.balanceMinor) {
      setState(() => _amountError =
          'Insufficient balance. You have ${Money.format(me.balanceMinor)}.');
      return;
    }
    // Client-side pre-flight against the monthly allowance for children.
    // Server-side enforcement (enforce_monthly_limit) is the source of truth;
    // this check is just for fast UX — it'll never let an over-limit transfer
    // through, but a borderline race is fine because the server will reject.
    if (me.role == UserRole.child) {
      final overLimit = _wouldExceedMonthlyLimit(me, amount);
      if (overLimit != null) {
        setState(() => _amountError = overLimit);
        return;
      }
    }
    setState(() {
      _busy = true;
      _amountError = null;
    });
    try {
      await ref.read(transactionsRepositoryProvider).transferMoney(
            receiverId: recipient.id,
            amountMinor: amount,
          );
      refreshBalancesAndMembers(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            content: Text(
              'Sent ${Money.format(amount)} to ${recipient.fullName}.',
            ),
          ),
        );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _amountError = _describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Returns a user-facing error string if [amount] would push [me]'s
  /// month-to-date outgoing total above their `monthly_limit_minor`.
  /// Returns `null` when there's no limit set or the transfer fits under it.
  ///
  /// Month boundary is **calendar month UTC** to match the server-side
  /// `enforce_monthly_limit` check exactly.
  String? _wouldExceedMonthlyLimit(Profile me, BigInt amount) {
    final controls =
        ref.read(dependentControlsProvider(me.id)).asData?.value;
    final limit = controls?.monthlyLimitMinor;
    if (limit == null) return null;
    final now = DateTime.now().toUtc();
    final monthStartUtc = DateTime.utc(now.year, now.month, 1);
    final all = ref.read(familyTransactionsProvider).asData?.value ??
        const <LedgerEntry>[];
    var mtd = BigInt.zero;
    for (final t in all) {
      if (t.senderId != me.id) continue;
      if (t.createdAt.toUtc().isBefore(monthStartUtc)) continue;
      mtd += t.amountMinor;
    }
    if (mtd + amount > limit) {
      return 'This transfer exceeds your monthly limit of ${Money.format(limit)}.';
    }
    return null;
  }

  Future<void> _pickRecipient(BuildContext context) async {
    final me = ref.read(myProfileProvider).asData?.value;
    final family = ref.read(familyMembersProvider).asData?.value ??
        const <Profile>[];
    final candidates = family.where((p) => p.id != me?.id).toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('No other family members yet.'),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    final picked = await showModalBottomSheet<Profile>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Pick a recipient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    )),
              ),
              for (final p in candidates)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AvatarUtils.colorFor(p.id),
                    child: Text(
                      AvatarUtils.initial(p.fullName),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(p.fullName),
                  subtitle: Text(p.role.name),
                  onTap: () => Navigator.of(ctx).pop(p),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _recipient = picked);
      _amountFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildRecipientPill(),
                    const SizedBox(height: 48),
                    _buildAmountInput(),
                    const SizedBox(height: 16),
                    if (_amountError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        child: Text(
                          _amountError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildQuickAmountChips(),
                  ],
                ),
              ),
            ),
            _buildBottomActionArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background.withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.onSurface),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Send Money',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildRecipientPill() {
    final r = _recipient;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => _pickRecipient(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To:',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (r != null) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: AvatarUtils.colorFor(r.id),
                child: Text(
                  AvatarUtils.initial(r.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                r.fullName,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.unfold_more,
                  color: AppColors.onSurfaceVariant, size: 16),
            ] else
              const Text(
                'Pick recipient',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        const Text(
          'ENTER AMOUNT',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicWidth(
          child: TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -2.0,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: AppColors.surfaceContainerHighest),
              prefixText: 'Rs. ',
              prefixStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(500),
        const SizedBox(width: 12),
        _buildChip(1000),
        const SizedBox(width: 12),
        _buildChip(5000),
      ],
    );
  }

  Widget _buildChip(int amount) {
    return ActionChip(
      onPressed: () => _addQuickAmount(amount),
      backgroundColor: AppColors.surfaceContainerLowest,
      side: const BorderSide(color: AppColors.surfaceContainerHighest),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      label: Text(
        '+$amount',
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
              color: AppColors.surfaceContainerHighest.withOpacity(0.5)),
        ),
      ),
      child: ElevatedButton(
        onPressed: _busy ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _busy
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Send Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

String _describeError(Object e) {
  final msg = e.toString();
  if (msg.contains('Insufficient balance')) return 'Insufficient balance.';
  if (msg.contains('Cannot send')) return 'You cannot send to yourself.';
  if (msg.contains('different family') || msg.contains('Cross-family')) {
    return 'That person is not in your family.';
  }
  if (msg.contains('Not authenticated')) return 'Please sign in again.';
  // Surface the server-side monthly-limit rejection from
  // public.enforce_monthly_limit. The function raises with a stable token
  // (MONTHLY_LIMIT_EXCEEDED) plus the limit in minor units so we can
  // re-render it with proper currency formatting on the client.
  if (msg.contains('MONTHLY_LIMIT_EXCEEDED')) {
    final match = RegExp(r'MONTHLY_LIMIT_EXCEEDED:(\d+)').firstMatch(msg);
    if (match != null) {
      final limitMinor = BigInt.tryParse(match.group(1)!);
      if (limitMinor != null) {
        return 'This transfer exceeds your monthly limit of ${Money.format(limitMinor)}.';
      }
    }
    return 'This transfer exceeds your monthly limit.';
  }
  return 'Could not send. Please try again.';
}
