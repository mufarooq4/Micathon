import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/avatar_utils.dart';

class AppColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color primary = Color(0xFF00502C);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);
  static const Color error = Color(0xFFBA1A1A);
}

/// Request money flow. Pass [initialApprover] from a profile screen, or
/// leave null to let the user pick a parent from their family.
class RequestMoneyScreen extends ConsumerStatefulWidget {
  const RequestMoneyScreen({super.key, this.initialApprover});

  final Profile? initialApprover;

  @override
  ConsumerState<RequestMoneyScreen> createState() =>
      _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends ConsumerState<RequestMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  Profile? _approver;
  bool _busy = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _approver = widget.initialApprover;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_approver != null) _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final approver = _approver;
    if (approver == null) {
      setState(() => _amountError = 'Pick a parent to request from.');
      return;
    }
    final amount = Money.parseMajorToMinor(_amountController.text);
    if (amount == null) {
      setState(() => _amountError = 'Enter a positive amount.');
      return;
    }
    setState(() {
      _busy = true;
      _amountError = null;
    });
    try {
      await ref.read(requestsRepositoryProvider).createRequest(
            approverId: approver.id,
            amountMinor: amount,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text(
            'Requested ${Money.format(amount)} from ${approver.fullName}.',
          ),
        ));
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _amountError = _describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickApprover() async {
    final me = ref.read(myProfileProvider).asData?.value;
    final family = ref.read(familyMembersProvider).asData?.value ??
        const <Profile>[];
    final parents = family
        .where((p) => p.id != me?.id && p.role == UserRole.parent)
        .toList();
    if (parents.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('No parents in your family yet.'),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    final picked = await showModalBottomSheet<Profile>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Request from',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface)),
            ),
            for (final p in parents)
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
                subtitle: const Text('Parent'),
                onTap: () => Navigator.of(ctx).pop(p),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _approver = picked);
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildRecipientPill(),
                    const SizedBox(height: 40),
                    _buildAmountInput(),
                    const SizedBox(height: 16),
                    if (_amountError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _amountError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
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
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.onSurface),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text('Request Funds',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
    );
  }

  Widget _buildRecipientPill() {
    final a = _approver;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: _pickApprover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Requesting from:',
                style: TextStyle(
                    fontSize: 14, color: AppColors.onSurfaceVariant)),
            const SizedBox(width: 8),
            if (a != null) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: AvatarUtils.colorFor(a.id),
                child: Text(
                  AvatarUtils.initial(a.fullName),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(a.fullName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              const Icon(Icons.unfold_more,
                  color: AppColors.onSurfaceVariant, size: 16),
            ] else
              const Text('Pick parent',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        const Text(
          'HOW MUCH DO YOU NEED?',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
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
                  color: AppColors.primary),
            ),
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
            top: BorderSide(
                color: AppColors.surfaceContainerHighest.withOpacity(0.5))),
      ),
      child: ElevatedButton(
        onPressed: _busy ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
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
            : const Text('Send Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

String _describeError(Object e) {
  final msg = e.toString();
  if (msg.contains('Approver not found')) return 'That parent is not in your family.';
  if (msg.contains('approve money requests')) return 'You can only request from a parent.';
  if (msg.contains('Cannot request from yourself')) {
    return 'You cannot request from yourself.';
  }
  if (msg.contains('Not authenticated')) return 'Please sign in again.';
  return 'Could not create request. Please try again.';
}
