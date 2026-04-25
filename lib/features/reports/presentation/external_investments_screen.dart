import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/translation_provider.dart';
import '../providers/external_investment_provider.dart';

class ExternalInvestmentsScreen extends ConsumerWidget {
  const ExternalInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final investmentsAsync = ref.watch(externalInvestmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('বাহ্যিক বিনিয়োগসমূহ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(externalInvestmentsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        label: const Text('নতুন বিনিয়োগ'),
        icon: const Icon(Icons.add_business_rounded),
      ),
      body: investmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_center_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('এখনো কোনো বাহ্যিক বিনিয়োগ রেকর্ড করা হয়নি।'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isActive = item['status'] == 'active';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'সক্রিয়' : 'বন্ধ',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('বিনিয়োগের তারিখ: ${item['investment_date']}'),
                      if (item['notes'] != null) ...[
                        const SizedBox(height: 4),
                        Text('নোট: ${item['notes']}', style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳ ${item['amount']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
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

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন বাহ্যিক বিনিয়োগ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'বিনিয়োগের নাম (উদা: জমি ক্রয়)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'পরিমাণ (৳)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'মন্তব্য (ঐচ্ছিক)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || amountController.text.isEmpty) return;
              await ref.read(externalInvestmentActionProvider).addInvestment(
                title: titleController.text.trim(),
                amount: double.parse(amountController.text),
                notes: notesController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }
}
