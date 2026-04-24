import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('হিসাব-নিকাশ (Reports)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(reportsProvider),
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
                _ReportRow(label: 'আজকের কিস্তি জমা:', amount: stats['today_installment'], color: Colors.purple),
                const Divider(height: 32),
                _ReportRow(label: 'সর্বমোট আজকের কালেকশন:', amount: stats['today_total'], color: Colors.blue, isBold: true),
                
                const SizedBox(height: 48),

                _SectionTitle(title: 'চলতি মাসের কালেকশন (${stats['month_name']})', icon: Icons.calendar_month_rounded, color: Colors.orange),
                const SizedBox(height: 16),
                _ReportRow(label: 'মাসিক সঞ্চয় জমা:', amount: stats['month_savings'], color: Colors.teal),
                _ReportRow(label: 'মাসিক কিস্তি জমা:', amount: stats['month_installment'], color: Colors.purple),
                const Divider(height: 32),
                _ReportRow(label: 'সর্বমোট মাসিক কালেকশন:', amount: stats['month_total'], color: Colors.orange, isBold: true),
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
}
