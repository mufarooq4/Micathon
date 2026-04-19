import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_category.dart';
import '../models/money.dart';
import '../models/profile.dart';
import '../models/transaction.dart';
import '../state/family_providers.dart';
import '../state/profile_providers.dart';
import 'Sendmoney12.dart' show AppColors;

/// Local copies of the colour tokens used by the limits cards on
/// `childhome5.dart`. Kept here so this screen stays self-contained and we
/// don't reach across into a private const from another file.
const Color _limitsGreen = Color(0xFF006B3C);
const Color _limitsGreenBg = Color(0xFFD9EEDF);
const Color _limitsTextDark = Color(0xFF0F172A);
const Color _limitsTextGrey = Color(0xFF6B7280);

/// "Add expense" flow. Lets a signed-in user (parent or child) record a
/// spend they made outside the family, deduct it from their balance, and
/// have it appear at the top of recent activity. For child users, the
/// existing month-to-date allowance check applies — Save is disabled and
/// labelled if the typed amount would push them over the cap.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  ExpenseCategory? _category;
  bool _busy = false;
  String? _formError;

  static const int _descMaxLength = 80;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // ---------- Validation helpers ----------------------------------------

  BigInt? get _parsedAmount =>
      Money.parseMajorToMinor(_amountController.text);

  String get _trimmedDescription => _descriptionController.text.trim();

  /// `null` when there's no monthly cap or the amount fits under it; a
  /// user-facing error string otherwise. Mirrors `_wouldExceedMonthlyLimit`
  /// in `Sendmoney12.dart` exactly so transfer + expense use the same
  /// month-to-date math.
  String? _wouldExceedMonthlyLimit(Profile me, BigInt amount) {
    if (me.role != UserRole.child) return null;
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
      return 'This expense exceeds your monthly limit of '
          '${Money.format(limit)}.';
    }
    return null;
  }

  /// Returns null when the form is submittable; otherwise an error string
  /// that's safe to show on the bottom of the form. Doesn't mutate state.
  String? _validate(Profile me) {
    final amount = _parsedAmount;
    if (amount == null) {
      return 'Enter a positive amount (e.g. 250 or 250.00).';
    }
    if (amount > me.balanceMinor) {
      return 'Insufficient balance. You have '
          '${Money.format(me.balanceMinor)}.';
    }
    if (_trimmedDescription.isEmpty) {
      return 'Describe what you spent on.';
    }
    if (_category == null) {
      return 'Pick a category.';
    }
    final overLimit = _wouldExceedMonthlyLimit(me, amount);
    if (overLimit != null) return overLimit;
    return null;
  }

  Future<void> _submit(Profile me) async {
    final error = _validate(me);
    if (error != null) {
      setState(() => _formError = error);
      return;
    }
    setState(() {
      _busy = true;
      _formError = null;
    });
    try {
      final id =
          await ref.read(transactionsRepositoryProvider).logExpense(
                amountMinor: _parsedAmount!,
                description: _trimmedDescription,
                category: _category!,
              );
      // Force-fresh balance + family snapshot. Mirrors the pattern in
      // `lib/state/family_providers.dart` so the home hero updates the
      // moment we pop, even if Realtime UPDATEs are slow.
      refreshBalancesAndMembers(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            content: Text(
              'Logged ${Money.format(_parsedAmount!)} on '
              '${_category!.displayName.toLowerCase()}.',
            ),
          ),
        );
      Navigator.of(context).pop<String>(id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _formError = _describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---------- Build ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider).asData?.value;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Add expense',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAmountInput(),
                          if (profile.role == UserRole.child) ...[
                            const SizedBox(height: 12),
                            _RemainingThisMonthHint(profile: profile),
                          ],
                          const SizedBox(height: 32),
                          _buildDescriptionField(),
                          const SizedBox(height: 32),
                          _buildCategorySection(),
                          const SizedBox(height: 24),
                          if (_formError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                _formError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActionArea(profile),
                ],
              ),
            ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        const Text(
          'AMOUNT SPENT',
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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
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
              hintStyle:
                  TextStyle(color: AppColors.surfaceContainerHighest),
              prefixText: 'Rs. ',
              prefixStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            onChanged: (_) {
              if (_formError != null) setState(() => _formError = null);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'WHAT DID YOU SPEND ON?',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        TextField(
          controller: _descriptionController,
          maxLength: _descMaxLength,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontSize: 16,
            color: _limitsTextDark,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. PlayStation Network',
            hintStyle: const TextStyle(
              color: _limitsTextGrey,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            counterStyle: const TextStyle(
              fontSize: 11,
              color: _limitsTextGrey,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _limitsGreen, width: 2),
            ),
          ),
          onChanged: (_) {
            if (_formError != null) setState(() => _formError = null);
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'CATEGORY',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in ExpenseCategory.values)
              _CategoryChip(
                category: c,
                selected: _category == c,
                onTap: () {
                  setState(() {
                    _category = c;
                    if (_formError != null) _formError = null;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActionArea(Profile profile) {
    final canSubmit = !_busy && _validate(profile) == null;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceContainerHighest.withOpacity(0.5),
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submit(profile) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _limitsGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _limitsGreen.withOpacity(0.4),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
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
                'Save expense',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

/// Small live "Remaining this month" hint shown to children only. Re-renders
/// whenever the month-to-date outgoing total or the amount input changes.
class _RemainingThisMonthHint extends ConsumerWidget {
  const _RemainingThisMonthHint({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlsAsync = ref.watch(dependentControlsProvider(profile.id));
    final limit = controlsAsync.asData?.value?.monthlyLimitMinor;
    if (limit == null) return const SizedBox.shrink();

    final all = ref.watch(familyTransactionsProvider).asData?.value ??
        const <LedgerEntry>[];
    final now = DateTime.now().toUtc();
    final monthStartUtc = DateTime.utc(now.year, now.month, 1);
    var mtd = BigInt.zero;
    for (final t in all) {
      if (t.senderId != profile.id) continue;
      if (t.createdAt.toUtc().isBefore(monthStartUtc)) continue;
      mtd += t.amountMinor;
    }
    final remaining = limit - mtd;
    final negative = remaining.isNegative;
    final color = negative ? AppColors.error : _limitsTextGrey;
    final label = negative
        ? 'Over your monthly limit by ${Money.format(-remaining)}'
        : '${Money.format(remaining)} left of your monthly limit';
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : _limitsGreen;
    final bg = selected ? _limitsGreen : _limitsGreenBg;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? _limitsGreen : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, color: fg, size: 18),
            const SizedBox(width: 8),
            Text(
              category.displayName,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _describeError(Object e) {
  final msg = e.toString();
  if (msg.contains('Insufficient balance')) return 'Insufficient balance.';
  if (msg.contains('Not authenticated')) return 'Please sign in again.';
  if (msg.contains('Caller has no family')) {
    return 'You need to be in a family to log expenses.';
  }
  if (msg.contains('Description')) {
    return 'Please enter a short description (1–80 characters).';
  }
  if (msg.contains('Invalid category')) return 'Please pick a category.';
  if (msg.contains('Amount must be positive')) {
    return 'Enter a positive amount.';
  }
  // Server-side monthly cap (mirrors public.enforce_monthly_limit). The
  // RAISE encodes the limit as `MONTHLY_LIMIT_EXCEEDED:<minor units>` so
  // we can re-render it client-side with proper currency formatting.
  if (msg.contains('MONTHLY_LIMIT_EXCEEDED')) {
    final match = RegExp(r'MONTHLY_LIMIT_EXCEEDED:(\d+)').firstMatch(msg);
    if (match != null) {
      final limitMinor = BigInt.tryParse(match.group(1)!);
      if (limitMinor != null) {
        return 'This expense exceeds your monthly limit of '
            '${Money.format(limitMinor)}.';
      }
    }
    return 'This expense exceeds your monthly limit.';
  }
  // Common "you forgot to run the SQL migration" failure modes — these
  // are by far the most likely causes the first time someone tries this
  // flow against a fresh Supabase project.
  if (msg.contains('Could not find the function') ||
      msg.contains('does not exist') ||
      msg.contains('PGRST202')) {
    return 'The log_expense function is not deployed yet. Run '
        'supabase/migrations/20260419120000_add_expense_kind.sql in the '
        'Supabase SQL Editor.';
  }
  if (msg.contains('violates row-level security')) {
    return "Server denied the insert (RLS). Check that the "
        "transactions_family_select policy allows kind='expense' rows.";
  }
  // Postgrest packs the useful message inside `message: ...,`. Surface it
  // verbatim so we can debug what's really going wrong instead of hiding
  // behind a generic fallback.
  final match = RegExp(r'message:\s*([^,)]+)').firstMatch(msg);
  if (match != null) {
    final detail = match.group(1)!.trim();
    if (detail.isNotEmpty) return 'Could not log expense: $detail';
  }
  return 'Could not log expense: $msg';
}
