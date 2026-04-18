import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/money_request.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/state/family_providers.dart';

/// Child's "My Requests" outbox. Shows every money request the current
/// user has created (any status), and lets them cancel pending ones.
class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  static const Color primaryColor = Color(0xFF006B3C);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color bgColor = Color(0xFFFAF9F3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outgoing = ref.watch(myOutgoingRequestsProvider);
    final family = ref.watch(familyMembersProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCFB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'My Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: darkGreen,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: outgoing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load requests: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) return _empty();
          final members = family.asData?.value ?? const <Profile>[];
          final byId = {for (final p in members) p.id: p};
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _RequestTile(
              request: list[i],
              approver: byId[list[i].approverId ?? ''],
            ),
          );
        },
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'You haven’t made any requests yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends ConsumerStatefulWidget {
  const _RequestTile({required this.request, required this.approver});

  final MoneyRequest request;
  final Profile? approver;

  @override
  ConsumerState<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends ConsumerState<_RequestTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final approverName = widget.approver?.fullName ?? 'a parent';
    final color = _statusColor(r.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MyRequestsScreen.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.call_received,
                  color: MyRequestsScreen.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To $approverName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: MyRequestsScreen.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(r.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Money.format(r.amountMinor),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: MyRequestsScreen.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              if (r.isPending)
                _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _cancel,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _cancel() async {
    setState(() => _busy = true);
    try {
      await ref.read(requestsRepositoryProvider).actOnRequest(
            requestId: widget.request.id,
            action: 'cancel',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Request cancelled.'),
          behavior: SnackBarBehavior.floating,
        ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Could not cancel: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Color _statusColor(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return Colors.amber.shade700;
      case RequestStatus.approved:
      case RequestStatus.executed:
        return MyRequestsScreen.primaryColor;
      case RequestStatus.declined:
      case RequestStatus.cancelled:
        return Colors.red.shade400;
      case RequestStatus.unknown:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(DateTime ts) {
    final l = ts.toLocal();
    return '${l.day}/${l.month}/${l.year}';
  }
}
