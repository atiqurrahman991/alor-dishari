import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(reportsProvider);
    final collectionAsync = ref.watch(collectionReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('হিসাব-নিকাশ (Reports)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(reportsProvider);
              ref.invalidate(collectionReportProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.error))),
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(title: 'আজকের কালেকশন', icon: Icons.today_rounded, color: Colors.blue),
                const SizedBox(height: 16),
                _ReportRow(label: 'আজকের সঞ্চয় জমা:', amount: stats['today_savings'], color: Colors.teal),
                _ReportRow(label: 'আজকের বিনিয়োগ ফেরত:', amount: stats['today_installment'], color: Colors.purple),
                const Divider(height: 32),
                _ReportRow(label: 'সর্বমোট আজকের কালেকশন:', amount: stats['today_total'], color: Colors.blue, isBold: true),
                
                const SizedBox(height: 48),

                _SectionTitle(title: 'চলতি মাসের কালেকশন (${stats['month_name']})', icon: Icons.calendar_month_rounded, color: Colors.orange),
                const SizedBox(height: 16),
                _ReportRow(label: 'মাসিক সঞ্চয় জমা:', amount: stats['month_savings'], color: Colors.teal),
                _ReportRow(label: 'মাসিক বিনিয়োগ ফেরত:', amount: stats['month_installment'], color: Colors.purple),
                const Divider(height: 32),
                _ReportRow(label: 'সর্বমোট মাসিক কালেকশন:', amount: stats['month_total'], color: Colors.orange, isBold: true),

                const SizedBox(height: 48),
                _buildCollectionAnalysis(context, ref, collectionAsync, theme),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isBold;

  const _ReportRow({required this.label, required this.amount, required this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 18 : 16,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '৳ ${amount.toStringAsFixed(2)}',
            style: style?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

Widget _buildCollectionAnalysis(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> collectionAsync, ThemeData theme) {
  return collectionAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, st) => Text('Error: $e'),
    data: (data) {
      final dueMembers = data['due_members'] as List;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'কালেকশন বিশ্লেষণ (এই মাস)', icon: Icons.analytics_rounded, color: Colors.green),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _AnalysisRow(label: 'মোট সদস্য:', value: '${data['total_members']} জন'),
                  _AnalysisRow(label: 'আদায় হওয়ার কথা:', value: '৳ ${data['expected_collection']}'),
                  _AnalysisRow(label: 'প্রকৃত আদায়:', value: '৳ ${data['actual_collection']}', color: Colors.green),
                  const Divider(height: 24),
                  _AnalysisRow(label: 'বকেয়া আছে:', value: '৳ ${data['expected_collection'] - data['actual_collection']}', color: Colors.red, isBold: true),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: 'বকেয়া তালিকা (${data['due_count']})', icon: Icons.warning_amber_rounded, color: Colors.red),
              if (dueMembers.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    // Implementation for reminding all via SMS/Notification could go here
                  },
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: const Text('সবাইকে তাগাদা দিন'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (dueMembers.isEmpty)
            const Center(child: Text('এই মাসে সবার কালেকশন সম্পন্ন হয়েছে! 🎉'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dueMembers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = dueMembers[index];
                return ListTile(
                  tileColor: theme.colorScheme.errorContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('মোবাইল: ${member['mobile']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('বকেয়া: ৳ ${member['due']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text('জমা: ৳ ${member['paid']}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}

class _AnalysisRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _AnalysisRow({required this.label, required this.value, this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
