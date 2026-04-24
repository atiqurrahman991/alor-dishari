import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/translation_provider.dart';
import 'ledger_provider.dart';

class LedgerScreen extends ConsumerWidget {
  final String memberId;
  final String memberName;

  const LedgerScreen({
    super.key, 
    required this.memberId,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tr = ref.watch(translationProvider);
    final ledgerAsync = ref.watch(ledgerProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$memberName - ${tr[Tr.viewLedger]}'),
      ),
      body: ledgerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 80, color: theme.colorScheme.surfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'কোনো ট্রানজেকশন পাওয়া যায়নি!',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isSavings = tx['type'] == 'savings';
              final date = DateTime.parse(tx['date']);
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isSavings ? Colors.teal : Colors.purple).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSavings ? Icons.savings_rounded : Icons.receipt_long_rounded,
                          color: isSavings ? Colors.teal : Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSavings ? 'সঞ্চয় জমা' : 'কিস্তি জমা',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'মাস: ${tx['month'] ?? 'N/A'} • মাধ্যম: ${tx['method'] ?? 'Cash'}',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (tx['trx_id'] != null && tx['trx_id'].toString().isNotEmpty)
                              Text('TrxID: ${tx['trx_id']}', style: theme.textTheme.bodySmall),
                            if (tx['notes'] != null && tx['notes'].toString().isNotEmpty)
                              Text('নোট: ${tx['notes']}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      Text(
                        '৳ ${tx['amount']}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isSavings ? Colors.teal : Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
