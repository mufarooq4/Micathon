import 'package:flutter/material.dart';

import '../models/money.dart';
import '../models/profile.dart';
import '../models/transaction.dart';
import 'avatar_utils.dart';

/// Renders a flat list of [LedgerEntry]s grouped by date, using the same
/// visual language as the existing Activity screens.
class LedgerList extends StatelessWidget {
  const LedgerList({
    super.key,
    required this.entries,
    required this.familyMembers,
    required this.currentUserId,
    this.emptyMessage = 'No transactions yet.',
  });

  final List<LedgerEntry> entries;
  final List<Profile> familyMembers;
  final String currentUserId;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3F1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 36, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDay(entries);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in grouped) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              group.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F4941),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F1),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final entry in group.entries)
                  _LedgerRow(
                    entry: entry,
                    counterparty:
                        _findProfile(entry.counterpartyFor(currentUserId)),
                    currentUserId: currentUserId,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Profile? _findProfile(String id) {
    for (final p in familyMembers) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<_DayGroup> _groupByDay(List<LedgerEntry> list) {
    final groups = <_DayGroup>[];
    DateTime? currentKey;
    List<LedgerEntry>? currentBucket;
    for (final e in list) {
      final local = e.createdAt.toLocal();
      final key = DateTime(local.year, local.month, local.day);
      if (currentKey == null || key != currentKey) {
        currentBucket = [];
        groups.add(_DayGroup(label: _labelFor(key), entries: currentBucket));
        currentKey = key;
      }
      currentBucket!.add(e);
    }
    return groups;
  }

  String _labelFor(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'TODAY';
    if (day == yesterday) return 'YESTERDAY';
    return '${day.day}/${day.month}/${day.year}'.toUpperCase();
  }
}

class _DayGroup {
  const _DayGroup({required this.label, required this.entries});
  final String label;
  final List<LedgerEntry> entries;
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.entry,
    required this.counterparty,
    required this.currentUserId,
  });

  final LedgerEntry entry;
  final Profile? counterparty;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final outgoing = entry.isOutgoingFor(currentUserId);
    final amountLabel = outgoing
        ? '-${Money.format(entry.amountMinor)}'
        : '+${Money.format(entry.amountMinor)}';
    final name = counterparty?.fullName ?? 'Family member';
    final color = AvatarUtils.colorFor(counterparty?.id ?? name);
    final initial = AvatarUtils.initial(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!outgoing) Container(width: 4, color: const Color(0xFF00502C)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outgoing ? 'Sent to $name' : 'Received from $name',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1C1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(entry.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3F4941),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      amountLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: outgoing
                            ? const Color(0xFF1A1C1A)
                            : const Color(0xFF00502C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime ts) {
    final l = ts.toLocal();
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
