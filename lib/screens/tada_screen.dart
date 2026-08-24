/// TA/DA screen — manage expense entries for a specific day.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tada_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/tada_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/tada_entry_card.dart';

class TadaScreen extends ConsumerStatefulWidget {
  final DateTime date;
  const TadaScreen({super.key, required this.date});

  @override
  ConsumerState<TadaScreen> createState() => _TadaScreenState();
}

class _TadaScreenState extends ConsumerState<TadaScreen> {
  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user != null) {
      ref.read(tadaDayProvider.notifier).loadForDate(user.id!, widget.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(tadaDayProvider);
    final user = ref.watch(authProvider);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final totalAmount = entries.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.date.day} ${monthNames[widget.date.month - 1]} ${widget.date.year}',
        ),
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('No TA/DA entries', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap + to add an expense entry.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : Column(
              children: [
                _TotalBanner(total: totalAmount, count: entries.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => TadaEntryCard(
                      entry: entries[i],
                      onEdit: () => _showForm(context, user, entry: entries[i]),
                      onDelete: () => _delete(entries[i]),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, user),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
      ),
    );
  }

  void _showForm(BuildContext context, dynamic user, {TadaEntry? entry}) {
    if (user == null) return;
    final purposeC = TextEditingController(text: entry?.purpose ?? '');
    final amountC = TextEditingController(text: entry != null ? entry.amount.toString() : '');
    final remarksC = TextEditingController(text: entry?.remarks ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry == null ? 'New TA/DA Entry' : 'Edit Entry', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: purposeC,
                decoration: const InputDecoration(labelText: 'Purpose', prefixIcon: Icon(Icons.description_outlined)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountC,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (৳)', prefixIcon: Icon(Icons.payments_outlined)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: remarksC,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Remarks (optional)', prefixIcon: Icon(Icons.notes_rounded)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final e = TadaEntry(
                      id: entry?.id,
                      userId: user.id!,
                      date: widget.date,
                      purpose: purposeC.text.trim(),
                      amount: double.parse(amountC.text.trim()),
                      remarks: remarksC.text.trim(),
                    );
                    if (entry == null) {
                      await ref.read(tadaDayProvider.notifier).addEntry(e);
                    } else {
                      await ref.read(tadaDayProvider.notifier).updateEntry(e);
                    }
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    ref.read(tadaProvider.notifier).loadForPayMonth(
                      user.id!,
                      ref.read(selectedPayMonthProvider),
                    );
                  },
                  child: Text(entry == null ? 'Add Entry' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(TadaEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Delete Entry'),
        content: Text('Delete "${entry.purpose}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(tadaDayProvider.notifier).deleteEntry(entry.id!, entry.userId, widget.date);
      ref.read(tadaProvider.notifier).loadForPayMonth(
        entry.userId,
        ref.read(selectedPayMonthProvider),
      );
    }
  }
}

class _TotalBanner extends StatelessWidget {
  final double total;
  final int count;
  const _TotalBanner({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.accent.withValues(alpha: 0.15), AppTheme.accent.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.accent),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total', style: Theme.of(context).textTheme.bodySmall),
            Text('৳ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.accent)),
          ]),
          const Spacer(),
          Text('$count ${count == 1 ? "entry" : "entries"}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
